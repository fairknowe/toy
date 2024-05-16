import { BrowserRouter } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { NavMenu } from "@shopify/app-bridge-react";
import Routes from "./Routes";

import {
  AppBridgeProvider,
  QueryProvider,
  PolarisProvider,
} from "./components";

// import { onCLS, onFID, onLCP } from 'web-vitals';

// onCLS(sendToAnalytics);
// onFID(sendToAnalytics);
// onLCP(sendToAnalytics);
// function sendToAnalytics(metric) {
//   //add code to send the metric to your analytics service
//   console.log(metric);
// }

import '@shopify/polaris-tokens/css/styles.css';


export default function App() {
  // Any .tsx or .jsx files in /pages will become a route
  // See documentation for <Routes /> for more info
  const pages = import.meta.globEager("./pages/**/!(*.test.[jt]sx)*.([jt]sx)");
  const { t } = useTranslation();

  return (
    <PolarisProvider>
      <BrowserRouter>
        <AppBridgeProvider>
          <QueryProvider>
            <NavMenu>
              <a href="/pagename">{t("NavMenu.pageName")}</a>
            </NavMenu>
            <Routes pages={pages} />
          </QueryProvider>
        </AppBridgeProvider>
      </BrowserRouter>
    </PolarisProvider>
  );
}
