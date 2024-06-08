# frozen_string_literal: true

class SubscriptionStatus < ApplicationService
    ACTIVE_SUBSCRIPTIONS_QUERY = <<~QUERY
    query currentAppInstallation {
      appInstallation {
        activeSubscriptions {
          id
          name
          status
          currentPeriodEnd
          returnUrl
          test
          trialDays
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

              }
            }
          }
          createdAt
        }
      }
    }
  QUERY

  def initialize(session:)
    super()
    @session = session
    @shop_domain = session.shop
  end

  def call
    Rails.logger.info("[#{self.class}] - Line #{__LINE__}: in SubscriptionStatus#call, session: #{@session.inspect}")
    client = ShopifyAPI::Clients::Graphql::Admin.new(session: @session)
    response = client.query(
      query: ACTIVE_SUBSCRIPTIONS_QUERY,
    )
    Rails.logger.info("[#{self.class}] - Line #{__LINE__}: in SubscriptionStatus#call, response: #{response.inspect}")
    process_response(response)
  end

  private

  def process_response(response)
    errors = response.body.dig("errors")
    if errors.present?
      return { success: false, queryError: errors[0]["message"], status_code: 200 }
    end

    appInstallation = response.body.dig("data", "appInstallation")
    if appInstallation.nil?
      { success: false, queryError: "No app installation information is available", status_code: 200, shop_domain: @shop_domain }
    elsif appInstallation.is_a?(Hash)
        return { success: false, queryError: "No app installation information is available", status_code: 200, shop_domain: @shop_domain } if appInstallation.empty?

        activeSubscriptions = response.body.dig("data", "appInstallation", "activeSubscriptions")
        return { success: false, queryError: "No active subscriptions information is available", status_code: 200, shop_domain: @shop_domain } if activeSubscriptions.empty?

      Rails.logger.info("[#{self.class}] - Line #{__LINE__}: in SubscriptionStatus#call, activeSubscriptions: #{activeSubscriptions.inspect}")
      { success: true, activeSubscriptions: activeSubscriptions, status_code: 200, shop_domain: @shop_domain }
    else
      Rails.logger.warn("[#{self.class}] - Line #{__LINE__}: in SubscriptionStatus#process_response. appInstallation is of type #{appInstallation.class}.")
    end
  end
end
