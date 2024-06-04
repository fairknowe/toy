import { useState } from "react";
import { Card, BlockStack, InlineStack, Button, Text } from "@shopify/polaris";
import { useTranslation } from "react-i18next";
import { useAppQuery } from "../hooks";
import { useAppBridge } from "@shopify/app-bridge-react";

// ProductsCard.jsx
export function ProductsCard() {
  const [isLoading, setIsLoading] = useState(true);
  const shopify = useAppBridge();
  const { t } = useTranslation();
  const productsCount = 2;

  const {
    data = { count: 0 },
    refetch: refetchProductCount,
    isLoading: isLoadingCount,
    error
  } = useAppQuery({
    url: "/api/products/count",
    reactQueryOptions: {
      onSuccess: () => {
        setIsLoading(false);
      },
      onError: (err) => {
        console.error("Failed to load product count:", err);
        setIsLoading(false);
      },
    },
  });

  // Early return if there's an error
  if (error) {
    console.error("Error fetching data:", error);
    return <Text color="critical">{t("ProductsCard.errorLoadingData", { error: error.message || error.toString() })}</Text>;
  }
  const handlePopulate = async () => {
    setIsLoading(true);
    const response = await fetch("/api/products/create", {
      method: "POST",
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ count: productsCount })
    });
    const message = await response.json();

    if (message.success) {
      await refetchProductCount();
      const successMessage = t("ProductsCard.productsCreatedToast", { count: productsCount });
      shopify.toast.show(successMessage);

    } else {
      setIsLoading(false);
      const errorMessage = t("ProductsCard.errorCreatingProductsToast", { message_error: message.error });
      shopify.toast.show(errorMessage);
    }
  };

  return (
    <>
      <Card>
        <BlockStack gap="200">
          <Text as="h1" variant="headingSm">
            {t("ProductsCard.title")}
          </Text>
          <p>{t("ProductsCard.description")}</p>
          <BlockStack gap="200">
            <Text as="h4" variant="headingMd">
              {t("ProductsCard.totalProductsHeading")}
              <Text variant="bodyMd" as="p" fontWeight="semibold">
                {isLoadingCount ? "-" : data.count}
              </Text>
            </Text>
          </BlockStack>
          <InlineStack align="end">
            <Button loading={isLoading} onClick={handlePopulate}>
              {t("ProductsCard.populateProductsButton", {
                count: productsCount,
              })}
            </Button>
          </InlineStack>

        </BlockStack>
      </Card>
    </>
  );
}
