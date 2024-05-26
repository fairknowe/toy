// import { Redirect } from "@shopify/app-bridge/actions";
import { useAppBridge } from "@shopify/app-bridge-react";
import { useEffect, useState } from "react";
// import { useLocation } from "react-router-dom";
import { Banner, Layout, Page } from "@shopify/polaris";

export default function ExitIframe() {
  // const app = useAppBridge();
  // const { search } = useLocation();
  // console.log("ExitIframe -> search", search)
  const shopify = useAppBridge();
  const [showWarning, setShowWarning] = useState(false);

  // useEffect(() => {
  //   if (!!app && !!search) {
  //     const params = new URLSearchParams(search);
  //     console.log("ExitIframe -> params", params)
  //     const redirectUri = params.get("redirectUri");
  //     const url = new URL(decodeURIComponent(redirectUri));

  //     if (
  //       [location.hostname, "admin.shopify.com"].includes(url.hostname) ||
  //       url.hostname.endsWith(".myshopify.com")
  //     ) {
  //       const redirect = Redirect.create(app);
  //       redirect.dispatch(
  //         Redirect.Action.REMOTE,
  //         decodeURIComponent(redirectUri)
  //       );
  //     } else {
  //       setShowWarning(true);
  //     }
  //   }
  // }, [app, search, setShowWarning]);

  useEffect(() => {
    if (!!shopify) {
      const hostname = shopify.config.shop;
      if (hostname.endsWith(".myshopify.com")) {
        setShowWarning(false);
      } else {
        setShowWarning(true);
      }
    }
  }, [shopify]);

  return showWarning ? (
    <Page narrowWidth>
      <Layout>
        <Layout.Section>
          <div style={{ marginTop: "100px" }}>
            <Banner title="Redirecting outside of Shopify" status="warning">
              Apps can only use /exitiframe to reach Shopify or the app itself.
            </Banner>
          </div>
        </Layout.Section>
      </Layout>
    </Page>
  ) : (
    <Page narrowWidth>
      <Layout>
        <Layout.Section>
          <div style={{ marginTop: "100px" }}>
            <Banner title="Redirected to /Exitiframe" status="warning">
              Hello from /Exitiframe.
            </Banner>
          </div>
        </Layout.Section>
      </Layout>
    </Page>
    // shopify.loading(true)
  );
}
