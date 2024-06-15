import { useState, useCallback } from 'react';
import { Button } from "@shopify/polaris";
import { Modal, TitleBar, useAppBridge } from "@shopify/app-bridge-react";

export function SubscriptionCancelButton() {
    const shopify = useAppBridge();
    const modalID = "subscription-cancel-modal";
    const [queryErrorMessage, setQueryErrorMessage] = useState(null);
    const [subscriptionId, setSubscriptionId] = useState("");
    const [subscriptionStatus, setSubscriptionStatus] = useState("");
    const [modalOpen, setModalOpen] = useState(false);

    async function cancelSubscription() {
        try {
            const response = await fetch("/api/subscriptions/cancel", {
                method: "GET",
                headers: {
                    'Content-Type': 'application/json'
                },
            });
            const { success, appSubscriptionId, appSubscriptionStatus, queryError } = await response.json();

            if (!success && !queryError) {
                const errorMessage = "Failed to cancel App subscription: Unknown error";
                setQueryErrorMessage(errorMessage);
                console.error(errorMessage);
            } else if (queryError) {
                const errorMessage = `Failed to cancel App subscription. User error message: ${queryError}`;
                setQueryErrorMessage(errorMessage);
                console.error(errorMessage);
            } else {
                setSubscriptionId(appSubscriptionId);
                setSubscriptionStatus(appSubscriptionStatus);
                setQueryErrorMessage(null);
            }
            setModalOpen(true);
        } catch (error) {
            const errorMessage = `Error cancelling subscription: ${error.message || error.toString()}`;
            setQueryErrorMessage(errorMessage);
            console.error(errorMessage);
            setModalOpen(true);
        }
    }

    const handleButtonClick = useCallback(async () => {
        await cancelSubscription();
    }, []);

    const handleModalClose = () => {
        shopify.modal.hide(modalID);
        setModalOpen(false);
    };

    return (
        <>
            <Button onClick={handleButtonClick}>Subscription cancel</Button>
            <Modal id={modalID} open={modalOpen} onHide={handleModalClose} variant="large">
                <TitleBar title="Subscription Cancelled">
                    <button onClick={handleModalClose}>
                        Done
                    </button>
                </TitleBar>
                <div style={{ padding: '5px 10px' }}>
                    {queryErrorMessage ? (
                        <p style={{ color: 'red' }}>{queryErrorMessage}</p>
                    ) : (
                        <>
                            <div style={{ padding: '5px 10px' }}>
                                {`Subscription ID: ${subscriptionId}`}
                            </div>
                            <div style={{ padding: '5px 10px' }}>
                                {`Subscription Status: ${subscriptionStatus}`}
                            </div>
                        </>
                    )}
                </div>
            </Modal>
        </>
    );
}
