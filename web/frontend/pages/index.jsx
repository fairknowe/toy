import {
  Card,
  Page,
  Layout,
  BlockStack,
  Image,
  Link,
  Text,
  InlineGrid,
  Divider,
} from "@shopify/polaris";
import { themeDefault } from '@shopify/polaris-tokens';
import { TitleBar } from "@shopify/app-bridge-react";
import { useTranslation, Trans } from "react-i18next";

import { trophyImage } from "../assets";

import { ProductsCard, UsersCard } from "../components";

export default function HomePage() {
  const { t } = useTranslation();
  return (
    <Page narrowWidth>
      <TitleBar title={t("HomePage.title")} primaryAction={null} />
      <Layout>
        <Layout.Section>
          <Card>
            <InlineGrid columns={['twoThirds', 'oneThird']}>
              <BlockStack>
                <Text as="h2" variant="headingMd">
                  {t("HomePage.heading")}
                </Text>
                <p>
                  <Trans
                    i18nKey="HomePage.yourAppIsReadyToExplore"
                    components={{
                      PolarisLink: (
                        <Link
                          url="https://polaris.shopify.com/"
                          target="_blank"
                          monochrome={true}
                        />
                      ),
                      AdminApiLink: (
                        <Link
                          url="https://shopify.dev/api/admin-graphql"
                          target="_blank"
                          monochrome={true}
                        />
                      ),
                      AppBridgeLink: (
                        <Link
                          url="https://shopify.dev/apps/tools/app-bridge"
                          target="_blank"
                          monochrome={true}
                        />
                      ),
                    }}
                  />
                </p>
                <p>{t("HomePage.startPopulatingYourApp")}</p>
                <p>
                  <Trans
                    i18nKey="HomePage.learnMore"
                    components={{
                      ShopifyTutorialLink: (
                        <Link
                          url="https://shopify.dev/apps/getting-started/add-functionality"
                          target="_blank"
                          monochrome={true}
                        />
                      ),
                    }}
                  />
                </p>
              </BlockStack>
              <BlockStack align="start" inlineAlign="center">
                <Image
                  source={trophyImage}
                  alt={t("HomePage.trophyAltText")}
                  width={120}
                />
              </BlockStack>
            </InlineGrid>
            <br />
            <p></p>
            <Divider borderWidth='050' borderColor="border" />
            {/* <InlineGrid columns={['twoThirds', 'oneThird']}> */}
            <BlockStack align="center" inlineAlign="center">
              <Text variant="headingSm">{t("HomePage.appName")}</Text>
              <p>{t("HomePage.appDeveloper")}</p>
              <p>by</p>
              <p>
                <Trans
                  i18nKey="HomePage.appDeveloperLink"
                  components={{
                    FaireknoweIncLink: (
                      < Link
                        url="https://fairknowe.com"
                        target="_blank"
                        monochrome={false}
                        removeUnderline={true}
                      />
                    )
                  }}
                />
              </p>
            </BlockStack>
            {/* </InlineGrid> */}
          </Card>
        </Layout.Section>
        <Layout.Section>
          <UsersCard />
        </Layout.Section>
        <Layout.Section>
          <ProductsCard />
        </Layout.Section>
      </Layout>
    </Page >
  );
}
