import { useState } from 'react';
import { Button } from "@shopify/polaris";
import { useAppBridge } from "@shopify/app-bridge-react";
import { attachCloseButtonListener } from '../utils/closeButton';

export function HotwireTestButton() {
    const shopify = useAppBridge();
    const [error, setError] = useState(null);

    async function usePartial() {
        const shop_domain = shopify.config.shop;
        try {
            const response = await fetch(`/api/hotwire/update?shop_domain=${encodeURIComponent(shop_domain)}`, {
                method: "GET",
                headers: {
                    'Content-Type': 'application/json'
                },
            });
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            const data = await response.json();
            if (!data['message']) {
                throw new Error("Hotwire update failed");
            }
            attachCloseButtonListener(shopify.config.shop);
        } catch (error) {
            console.error("HotwireTestButton. Error fetching message:", error);
            setError(`HotwireTestButton. Error fetching message: ${error.message || error.toString()}`);
        }
    }

    return (
        <>
            <Button onClick={usePartial}>Hotwire test</Button>
            {error && <p>{error}</p>}
        </>
    );
}
