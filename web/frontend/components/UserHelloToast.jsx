import { Button } from "@shopify/polaris";
import { useAppBridge } from "@shopify/app-bridge-react";
import { useState, useEffect } from 'react';

export function UserHelloToast() {
    const shopify = useAppBridge();
    const [userID, setUserID] = useState(null);
    const [error, setError] = useState(null);

    async function generateToast() {
        try {
            const response = await fetch('/api/current/user');
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            const data = await response.json();
            if (!data['user']) {
                throw new Error("No user data found");
            }
            setUserID(data['user']['shopify_user_id']);
        } catch (error) {
            console.error("UserHelloToast. Error fetching user data:", error);
            setError(`UserHelloToast. Error fetching user data: ${error.message || error.toString()}`);
        }
    }
    useEffect(() => {
        if (userID) {
            shopify.toast.show(`Hello, user ${userID}!`);
            console.log("Success. shopify.toast.show(Hello, user" + userID + ")");
        }
    }, [userID]);

    return (
        <>
            <Button onClick={generateToast}>Toast test</Button>
            {error && <p>{error}</p>}
        </>
    );
}
