import { useState } from 'react';
import { Modal, TitleBar, useAppBridge } from "@shopify/app-bridge-react";
import { Button } from "@shopify/polaris";

export function UserReportModal() {
    const shopify = useAppBridge();
    const modalID = "user-report-modal";
    const [userAccountAccess, setUserAccountAccess] = useState(null);
    const [userID, setUserID] = useState(null);
    const [userScopes, setUserScopes] = useState(null);
    const [error, setError] = useState(null);

    async function generateModal() {
        try {
            console.log("shopify.environment", shopify.environment)
            const userData = await shopify.user();
            // console.log("userData.accountAccess:", userData.accountAccess)
            setUserAccountAccess(userData.accountAccess);
            const response = await fetch('/api/current/user');
            if (!response.ok) {
                throw new Error('Failed to fetch');
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
            // console.log("data:", data)
            if (!data['user']) {
                throw new Error("No user data found");
            }
            const shopifyUserID = data['user']['shopify_user_id'];
            // console.log("shopifyUserID:", shopifyUserID)
            setUserID(shopifyUserID);
            setUserScopes(data['user']['access_scopes']);
            if (userID) {
                console.log("shopify.modal.show(", modalID);
                await shopify.modal.show(modalID);
            }
        } catch (error) {
            console.error('UserReportModal. Error fetching user data:', error);
            setError(`UserReportModal. Error fetching user data: ${error.message || error.toString()}`);
        }
    }

    return (
        <div>
            <Button onClick={generateModal}>Modal test</Button>
            <Modal id={modalID} open={[shopify, userID, userScopes, userAccountAccess].every(Boolean)} onShow={() => console.log("UserReportModal is shown")} onHide={() => console.log("UserReportModal is hidden")} variant="base">
                <p style={{ padding: 5 }}>
                    {`User ${userID}, your account type is '${userAccountAccess}', with '${userScopes}' permission(s).`}
                </p>
                <TitleBar title={`User ${userID} Report`} >
                    <button onClick={() => shopify.modal.hide(modalID)}>Close</button>
                </TitleBar>
            </Modal>
            {error && <p>{error}</p>}
        </div>
    );
}
