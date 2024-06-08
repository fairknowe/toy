// SubscriptionStatusButton
import { useState, useCallback } from 'react';
import { Button } from "@shopify/polaris";
import { Modal, TitleBar, useAppBridge } from "@shopify/app-bridge-react";

export function SubscriptionStatusButton() {
    const shopify = useAppBridge();
    const modalID = "subscription-modal";
    const [queryErrorMessage, setQueryErrorMessage] = useState(null);
    const [appSubscriptions, setAppSubscriptions] = useState(null);
    const [modalOpen, setModalOpen] = useState(false);

    async function queryAppStatus() {
        const shop_domain = shopify.config.shop;
        try {
            const response = await fetch(`/api/subscriptions/status?shop_domain=${encodeURIComponent(shop_domain)}`, {
                method: "GET",
                headers: {
                    'Content-Type': 'application/json'
                },
            });
            const { success, activeSubscriptions, queryError } = await response.json();

            if (!success && !queryError) {
                const errorMessage = "Failed to retrieve App subscription: Unknown error";
                setQueryErrorMessage(errorMessage);
                console.error(errorMessage);
            } else if (queryError) {
                const errorMessage = `Failed to retrieve App subscription. User error message: ${queryError}`;
                setQueryErrorMessage(errorMessage);
                console.error(errorMessage);
            } else {
                setAppSubscriptions(activeSubscriptions);
                setQueryErrorMessage(null)
            }

            setModalOpen(true);
        } catch (error) {
            const errorMessage = `Error querying App status: ${error.message || error.toString()}`;
            setQueryErrorMessage(errorMessage);
            console.error(errorMessage);
            setModalOpen(true);
        }
    }

    const handleButtonClick = useCallback(async () => {
        await queryAppStatus();
    }, []);

    const handleModalClose = () => {
        shopify.modal.hide(modalID);
        setModalOpen(false);
    };

    const formatSubscriptionInfo = (subscriptions) => {
        const {
            id,
            name,
            status,
            trialDays,
            lineItems,
        } = subscriptions[0];

        const {
            interval,
            price: { amount, currencyCode }
        } = lineItems[0].plan.pricingDetails;

        return (
            <>
                <ul>
                    <li><strong>Name:</strong> {name}</li>
                    <li><strong>Status:</strong> {status}</li>
                    <li><strong>Trial Days:</strong> {trialDays}</li>
                    <li><strong>Price:</strong> {amount} {currencyCode} every {interval}</li>
                    <li><strong>Subscription ID:</strong> {id}</li>
                </ul>
            </>
        );
    };

    return (
        <>
            <Button onClick={handleButtonClick}>Subscription status</Button>
            <Modal id={modalID} open={modalOpen} onHide={handleModalClose} variant="large">
                <TitleBar title="Subscription Status Report">
                    <button variant="primary" onClick={handleModalClose}>
                        Close
                    </button>
                </TitleBar>
                <div style={{ padding: '5px 10px' }}>
                    {appSubscriptions ?
                        formatSubscriptionInfo(appSubscriptions)
                        :
                        (<p style={{ color: 'red' }}>{queryErrorMessage}</p>)
                    }
                </div>
            </Modal>
        </>
    );
}
