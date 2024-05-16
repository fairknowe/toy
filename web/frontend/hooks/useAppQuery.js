import { useMemo } from "react";
import { useQuery } from "react-query";
import { useAppBridge } from "@shopify/app-bridge-react";

/**
 * A hook for querying your custom app data.
 * @desc A thin wrapper around useAuthenticatedFetch and react-query's useQuery.
 *
 * @param {Object} options - The options for your query. Accepts 3 keys:
 *
 * 1. url: The URL to query. E.g: /api/widgets/1`
 * 2. fetchInit: The init options for fetch.  See: https://developer.mozilla.org/en-US/docs/Web/API/fetch#parameters
 * 3. reactQueryOptions: The options for `useQuery`. See: https://react-query.tanstack.com/reference/useQuery
 *
 * @returns Return value of useQuery.  See: https://react-query.tanstack.com/reference/useQuery.
 */
export const useAppQuery = ({ url, fetchInit = {}, reactQueryOptions }) => {
  const shopify = useAppBridge();
  const queryFetch = useMemo(() => {
    return async () => {
      // should probably make this into a function
      try {
        const response = await fetch('/api/products/count');
        const data = await response.json();
        return data;
      } catch (error) {
        // Handles network errors and logging
        console.error("Failed to fetch product count:", error);
        return {}; // Early return on error
      }

    };
  }, [url, JSON.stringify(fetchInit)]);

  return useQuery(url, queryFetch, {
    ...reactQueryOptions,
    refetchOnWindowFocus: false,
  });
};
