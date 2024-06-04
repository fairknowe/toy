import { useState } from 'react';
import { Button } from "@shopify/polaris";
import { useAppBridge } from "@shopify/app-bridge-react";

export function ToastTestButton() {
    const shopify = useAppBridge();
    const [error, setError] = useState(null);

    async function generateToast() {
        const shop_domain = shopify.config.shop;
        try {
            const response = await fetch(`/api/current/user?shop_domain=${encodeURIComponent(shop_domain)}`);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            const data = await response.json();
            if (!data['user']) {
                throw new Error("No user data found");
            }
            const userID = data['user']['shopify_user_id'];
            shopify.toast.show(`Hello, user ${userID}!`);
        } catch (error) {
            console.error("ToastTestButton. Error fetching user data:", error);
            setError(`ToastTestButton. Error fetching user data: ${error.message || error.toString()}`);
        }
    }

    return (
        <>
            <Button onClick={generateToast}>Toast test</Button>
            {error && <p>{error}</p>}
        </>
    );
}
