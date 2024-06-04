// import { useEffect } from "react";
import { Card, EmptyState, Page } from "@shopify/polaris";
import { useTranslation } from "react-i18next";
import { appErrorImage } from "../assets";


export default function ErrorHandler() {
  const currentUrl = window.location.href;
  const indexUrl = transformUrl(currentUrl);

  const logCurrentUrl = new URL(currentUrl);
  console.log("ErrorHandler -> currentUrl", logCurrentUrl.origin + logCurrentUrl.pathname);
  const logIndexUrl = new URL(indexUrl);
  console.log("ErrorHandler -> indexUrl", logIndexUrl.origin + logIndexUrl.pathname);

  if (currentUrl === indexUrl) {
    return null;
  }

  const { t } = useTranslation();

  return (
    <Page>
      <Card>
        <EmptyState heading={t("appError.heading")} image={appErrorImage}>
          <p>{t("appError.description")}</p>
          <p>Please try again.</p>
          <br />
          <button onClick={() => (window.location.href = indexUrl)}>Return to TOY</button>
        </EmptyState>
      </Card>
    </Page>
  );

}

function transformUrl(urlString) {
  const url = new URL(urlString);
  const newPathname = url.pathname.replace('/ErrorHandler', '');
  url.pathname = newPathname;
  return url.toString();
}
