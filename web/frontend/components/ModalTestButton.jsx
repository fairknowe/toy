import { useState, useCallback } from 'react';
import { Modal, TitleBar, useAppBridge } from "@shopify/app-bridge-react";
import { Button } from "@shopify/polaris";

export function ModalTestButton() {
    const shopify = useAppBridge();
    const modalID = "user-report-modal";
    const [userAccountAccess, setUserAccountAccess] = useState(null);
    const [userID, setUserID] = useState(null);
    const [userScopes, setUserScopes] = useState(null);
    const [error, setError] = useState(null);
    const [modalOpen, setModalOpen] = useState(false);

    const fetchUserData = useCallback(async () => {
        const shop_domain = shopify.config.shop;
        try {
            const userData = await shopify.user();
            setUserAccountAccess(userData.accountAccess);

            const response = await fetch(`/api/current/user?shop_domain=${encodeURIComponent(shop_domain)}`, {
                method: "GET",
                headers: {
                    'Content-Type': 'application/json'
                },
            });
            if (!response.ok) {
                throw new Error('Failed to fetch');
            }

            const text = await response.text();
            if (!text) {
                throw new Error("Empty response text");
            }

            const data = JSON.parse(text);
            if (!data['user']) {
                throw new Error("No user data found");
            }

            const shopifyUserID = data['user']['shopify_user_id'];
            setUserID(shopifyUserID);
            setUserScopes(data['user']['access_scopes']);
            setModalOpen(true); // Set modalOpen to true after state updates

        } catch (error) {
            console.error('Error fetching user data:', error);
            setError(`Error fetching user data: ${error.message || error.toString()}`);
        }
    }, [shopify]);

    const generateModal = useCallback(async () => {
        await fetchUserData();
    }, [fetchUserData]);

    return (
        <div>
            <Button onClick={generateModal}>Modal test</Button>
            <Modal id={modalID} open={modalOpen} variant="base">
                <p style={{ padding: 5 }}>
                    {`User ${userID}, your account type is '${userAccountAccess}', with '${userScopes}' permission(s).`}
                </p>
                <TitleBar title={`User ${userID} Report`} >
                    <button onClick={() => {
                        shopify.modal.hide(modalID);
                        setModalOpen(false);
                    }}>Close</button>
                </TitleBar>
            </Modal>
            {error && <p>{error}</p>}
        </div>
    );
}
