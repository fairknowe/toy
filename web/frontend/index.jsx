import App from "./App";
import { createRoot } from "react-dom/client";
import { initI18n } from "./utils/i18nUtils";
// import '@shopify/polaris-tokens/css/styles.css';
// import '@shopify/polaris/build/esm/styles.css';

const reportedTime = new Date().getTime();
window.renderStartTime = reportedTime;
// console.log("'/index.jsx` render '/App.jsx' start: " + new Date(reportedTime).toISOString());

// Calculate the time difference
const srcStartTime = window.srcStartTime || null;
if (srcStartTime) {
  const timeDifference = reportedTime - srcStartTime;
  console.log("'home/index' call to '/index.js' duration: " + timeDifference + "ms");
} else {
  console.warn("Start time not found. Unable to calculate time difference.");
};

initI18n().then(() => {
  const root = createRoot(document.getElementById("app"));
  root.render(<App />);
});
