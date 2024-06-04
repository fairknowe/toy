import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { dirname } from "path";
import { fileURLToPath } from "url";

if (
  process.env.npm_lifecycle_event === "build" &&
  !process.env.CI &&
  !process.env.SHOPIFY_API_KEY
) {
  console.warn(
    "\nBuilding the frontend app without an API key. The frontend build will not run without an API key. Set the SHOPIFY_API_KEY environment variable when running the build command.\n",
  );
}

const proxyOptions = {
  target: `http://0.0.0.0:${process.env.BACKEND_PORT}`,
  changeOrigin: false,
  secure: false,
  ws: false,
};

const host = process.env.HOST
  ? process.env.HOST.replace(/https?:\/\//, "")
  : "localhost";

let hmrConfig;
if (host === "localhost") {
  hmrConfig = {
    protocol: "ws",
    host: "localhost",
    port: process.env.FRONTEND_PORT,
    clientPort: process.env.FRONTEND_PORT,
  };
} else {
  hmrConfig = {
    protocol: "wss",
    host: host,
    port: process.env.FRONTEND_PORT,
    clientPort: 443,
  };
}

export default ({ mode }) => {
  console.log('host:', host)
  console.log('mode:', mode);
  console.log('root:', dirname(fileURLToPath(import.meta.url)));

  return defineConfig({
    root: dirname(fileURLToPath(import.meta.url)),
    plugins: [react()],
    define: {
      "process.env.SHOPIFY_API_KEY": JSON.stringify(process.env.SHOPIFY_API_KEY),
      __SHOPIFY_CLIENT_ID__: JSON.stringify(process.env.SHOPIFY_API_KEY),
    },
    resolve: {
      preserveSymlinks: true,
    },
    server: {
      host: "localhost",
      port: process.env.FRONTEND_PORT,
      hmr: hmrConfig,
      proxy: {
        "^/(\\?.*)?$": proxyOptions,
        "^/api(/|(\\?.*)?$)": proxyOptions,
        "^/cable": {
          target: `ws://0.0.0.0:${process.env.BACKEND_PORT}`,
          ws: true,
        }
      },
    },
  });
};
