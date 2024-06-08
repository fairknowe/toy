import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { ButtonGroup, Card, Text, Layout } from "@shopify/polaris";
import { useAppBridge } from "@shopify/app-bridge-react";
import { ModalTestButton, ToastTestButton, HotwireTestButton, SubscriptionCreateButton, SubscriptionStatusButton } from "../components";

export function UsersCard() {
    const [userAccountAccess, setUserAccountAccess] = useState(null);
    const [userID, setUserID] = useState(null);
    const [userScopes, setUserScopes] = useState(null);
    const [error, setError] = useState(null);
    const shopify = useAppBridge();
    const shop_domain = shopify.config.shop;
    const currentUrl = window.location.href;

    if (!shop_domain) {
        console.error(`UsersCard. No shop_domain found in appBridge config. Referrer: ${encodeURIComponent(currentUrl)}`);
        const navigate = useNavigate();
        navigate("/ErrorHandler");
    }

    useEffect(() => {
        const fetchData = async () => {
            try {
                const userData = await shopify.user();
                console.log("User accountAccess:", userData.accountAccess);
                setUserAccountAccess(userData.accountAccess);

                const response = await fetch(`/api/current/user?shop_domain=${encodeURIComponent(shop_domain)}`, {
                    method: "GET",
                    headers: {
                        'Content-Type': 'application/json'
                    },
                });
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }

                const text = await response.text();
                if (!text) {
                    throw new Error("Empty response text");
                }
                let data;
                try {
                    data = JSON.parse(text);
                } catch (error) {
                    throw new Error("Failed to parse JSON: " + error.message);
                }
                console.log("Shopify User ID:", data['user'].shopify_user_id);
                console.log("User Access Scopes:", data['user'].access_scopes);
                if (!data['user']) {
                    throw new Error("No user data found");
                }

                setUserID(data['user']['shopify_user_id']);
                setUserScopes(data['user']['access_scopes']);
                return;
            } catch (error) {
                console.error("UsersCard. Error fetching user data:", error);
                setError(`UsersCard. Error fetching user data: ${error.message || error.toString()}`);
                return null;
            }
        };
        fetchData();
    }, [shopify, currentUrl]);

    return (
        <>
            <Card sectioned>
                <Layout.Section>
                    <Text>userAccountAccess from appBridge: {userAccountAccess}</Text>
                    <Text>userID from User session repository: {userID}</Text>
                    <Text>userScopes from User session repository: {userScopes}</Text>
                </Layout.Section>
                <Layout.Section>
                    <ButtonGroup gap="tight">
                        <ToastTestButton />
                        <ModalTestButton />
                        <HotwireTestButton />
                        <SubscriptionCreateButton />
                        <SubscriptionStatusButton />
                    </ButtonGroup>
                </Layout.Section>
            </Card>
            {error && <p>{error}</p>}
        </>
    );
}
