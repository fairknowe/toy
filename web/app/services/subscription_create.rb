# frozen_string_literal: true

class SubscriptionCreate < ApplicationService
    CREATE_SUBSCRIPTION_MUTATION = <<~QUERY
    mutation AppSubscriptionCreate($name: String!, $lineItems: [AppSubscriptionLineItemInput!]!, $returnUrl: URL!, $test: Boolean, $trialDays: Int) {
      appSubscriptionCreate(name: $name, returnUrl: $returnUrl, lineItems: $lineItems, test: $test, trialDays: $trialDays) {
        userErrors {
          field
          message
        }
        appSubscription {
          id
          name
          status
          currentPeriodEnd
          returnUrl
          test
          trialDays
          createdAt
          lineItems {
            id
            plan {
              pricingDetails {
                ... on AppRecurringPricing {
                  interval
                  price {
                    amount
                    currencyCode
                  }
                  discount {
                    durationLimitInIntervals
                    remainingDurationInIntervals
                    priceAfterDiscount {
                      amount
                      currencyCode
                    }
                    value {
                      ... on AppSubscriptionDiscountAmount {
                        amount {
                          amount
                          currencyCode
                        }
                      }
                      ... on AppSubscriptionDiscountPercentage {
                        percentage
                      }
                    }
                  }
                }
                ... on AppUsagePricing {
                  terms
                  interval
                  balanceUsed {
                    amount
                    currencyCode
                  }
                  cappedAmount {
                    amount
                    currencyCode
                  }
                }
              }
            }
          }
        }
        confirmationUrl
      }
    }
  QUERY

  def initialize(session:)
    super()
    @session = session
    @shop_domain = session.shop
  end

  def call
    client = ShopifyAPI::Clients::Graphql::Admin.new(session: @session)
      variables = {
        "test": true,
        "trialDays": 7,
        "name": "TOY App Recurring Plan",
        "returnUrl": "https://#{@shop_domain}/admin/apps/toy-1",
        "lineItems": [
          {
            "plan": {
              "appRecurringPricingDetails": {
                "interval": "EVERY_30_DAYS",
                "price": {
                  "amount": 0.99,
                  "currencyCode": "USD",
                },
              },
            },
          },
        ],
      }

      response = client.query(
        query: CREATE_SUBSCRIPTION_MUTATION,
        variables: variables,
      )
      process_response(response)
  end

  private

  def process_response(response)
    errors = response.body.dig("errors")
    if errors.present?
      return { success: false, queryError: errors[0]["message"], status_code: 200 }
    end

    created_subscription = response.body.dig("data", "appSubscriptionCreate")
    if created_subscription.nil?
      return { success: false, queryError: "No subscription created", status_code: 200 }
    end
    userErrors = created_subscription["userErrors"] || []
    if userErrors.present?
      userField = userErrors[0]["field"] || "Unknown field."
      userError = userErrors[0]["message"] || "Unknown error."
      Rails.logger.error("Line #{__LINE__}: in SubscriptionCreate#process_response, userField: #{userField}, userError: #{userError}")
      return { success: false, queryError: "#{userField}: #{userError}", status_code: 200 }
    end

    app_subscription = created_subscription["appSubscription"]
    ProcessSubscriptionsJob.perform_later(@shop_domain, app_subscription)

    appSubscriptionId = created_subscription["appSubscription"]["id"]
    confirmationUrl = created_subscription["confirmationUrl"]
    { success: true, appSubscriptionId: appSubscriptionId, confirmationUrl: confirmationUrl, status_code: 200 }
  end
end
