import { useState, useCallback } from 'react';
import { Button } from "@shopify/polaris";
import { ExternalIcon } from '@shopify/polaris-icons';
import { Modal, TitleBar, useAppBridge } from "@shopify/app-bridge-react";

export function SubscriptionCreateButton() {
    const shopify = useAppBridge();
    const modalID = "billing-modal";
    const [queryErrorMessage, setQueryErrorMessage] = useState(null);
    const [subscriptionId, setSubscriptionId] = useState("");
    const [confirmChargesUrl, setConfirmChargesUrl] = useState("");
    const [modalOpen, setModalOpen] = useState(false);

    async function createSubscription() {
        try {
            const response = await fetch("/api/subscriptions/create", {
                method: "POST",
                headers: {
                    'Content-Type': 'application/json'
                },
            });
            const { success, appSubscriptionId, confirmationUrl, queryError } = await response.json();

            if (!success && !queryError) {
                const errorMessage = "Failed to create App subscription: Unknown error";
                setQueryErrorMessage(errorMessage);
                console.error(errorMessage);
            } else if (queryError) {
                const errorMessage = `Failed to create App subscription. User error message: ${queryError}`;
                setQueryErrorMessage(errorMessage);
                console.error(errorMessage);
            } else {
                setSubscriptionId(appSubscriptionId);
                setConfirmChargesUrl(confirmationUrl);
                setQueryErrorMessage(null);
            }
            setModalOpen(true);
        } catch (error) {
            const errorMessage = `Error creating subscription: ${error.message || error.toString()}`;
            setQueryErrorMessage(errorMessage);
            console.error(errorMessage);
            setModalOpen(true);
        }
    }

    const handleButtonClick = useCallback(async () => {
        await createSubscription();
    }, []);

    const handleModalClose = () => {
        shopify.modal.hide(modalID);
        setModalOpen(false);
    };

    return (
        <>
            <Button onClick={handleButtonClick}>Subscription create</Button>
            <Modal id={modalID} open={modalOpen} onHide={handleModalClose} variant="large">
                <TitleBar title="Approve Subscription">
                    <button onClick={handleModalClose}>
                        Cancel
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
                                {`Confirmation URL: ${confirmChargesUrl}`}
                            </div>
                            <div style={{ padding: '5px 10px' }}>
                                <Button
                                    tone={'success'}
                                    accessibilityLabel="Confirm subscription (opens a new window)"
                                    icon={ExternalIcon}
                                    url={confirmChargesUrl}>
                                    Confirm subscription
                                </Button>
                            </div>
                        </>
                    )}
                </div>
            </Modal>
        </>
    );
}
