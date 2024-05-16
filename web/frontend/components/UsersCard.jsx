import { useState, useEffect } from "react";
import { ButtonGroup, Card, Text, Layout } from "@shopify/polaris";
import { useAppBridge } from "@shopify/app-bridge-react";
import { UserReportModal, UserHelloToast } from "../components";

export function UsersCard() {
    const [userAccountAccess, setUserAccountAccess] = useState(null);
    const [userID, setUserID] = useState(null);
    const [userScopes, setUserScopes] = useState(null);
    const [error, setError] = useState(null);
    const shopify = useAppBridge();

    useEffect(() => {
        const fetchData = async () => {
            const maxRetries = 3; // Maximum number of retries
            const retryDelay = 2000; // Delay between retries in milliseconds

            for (let attempt = 1; attempt <= maxRetries; attempt++) {
                try {
                    const userData = await shopify.user();
                    console.log("from App Bridge:");
                    console.log("User accountAccess:", userData.accountAccess);
                    setUserAccountAccess(userData.accountAccess);

                    const response = await fetch('/api/current/user');
                    // console.log("fetch('/api/current/user') response:", response);
                    if (!response.ok) {
                        throw new Error(`HTTP error! status: ${response.status}`);
                    }

                    const text = await response.text();
                    if (!text) {
                        throw new Error("Empty response text");
                    }
                    // console.log("fetch('/api/current/user') response:", text);
                    let data;
                    try {
                        data = JSON.parse(text);  // Manually parse text to JSON
                    } catch (error) {
                        throw new Error("Failed to parse JSON: " + error.message);
                    }
                    console.log("from User Session Repository:");
                    console.log("Shopify User ID:", data['user'].shopify_user_id, "User Access Scopes:", data['user'].access_scopes);
                    if (!data['user']) {
                        throw new Error("No user data found");
                    }

                    setUserID(data['user']['shopify_user_id']);
                    setUserScopes(data['user']['access_scopes']);
                    return;
                } catch (error) {
                    if (attempt === maxRetries) {
                        console.error("UsersCard. maxRetries reached:", maxRetries);
                        console.error("UsersCard. Error fetching user data:", error);
                        setError(`UsersCard. Error fetching user data: ${error.message || error.toString()}`);
                        return; // Stop trying after reaching max retries
                    }
                    await new Promise(resolve => setTimeout(resolve, retryDelay)); // Wait before retrying
                }
            }
        };

        fetchData();
    }, [shopify]);

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
                        <UserReportModal />
                        <UserHelloToast />
                    </ButtonGroup>
                </Layout.Section>
            </Card>
            {error && <p>{error}</p>}
        </>
    );
}
