# frozen_string_literal: true

class SubscriptionExtendTrial < ApplicationService
    EXTEND_SUBSCRIPTION_MUTATION = <<~QUERY
    mutation AppSubscriptionTrialExtend($id: ID!, $days: Int!) {
        appSubscriptionTrialExtend(id: $id, days: $days) {
          userErrors {
            field
            message
            code
          }
          appSubscription {
            id
            status
            trialDays
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
    subscription_id = Subscription.find_by(shopify_domain: @shop_domain, status: "ACTIVE").subscription_id
    client = ShopifyAPI::Clients::Graphql::Admin.new(session: @session)
      variables = {
        "id": subscription_id,
        "days": 1,
      }

      response = client.query(
        query: EXTEND_SUBSCRIPTION_MUTATION,
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

    subscription_extended = response.body.dig("data", "appSubscriptionTrialExtend")
    if subscription_extended.nil?
      return { success: false, queryError: "No subscription extended", status_code: 200 }
    end
    userErrors = subscription_extended["userErrors"] || []
    if userErrors.present?
      userField = userErrors[0]["field"] || "Unknown field."
      userError = userErrors[0]["message"] || "Unknown error."
      return { success: false, queryError: "#{userField}: #{userError}", status_code: 200 }
    end

    appSubscriptionId = subscription_extended["appSubscription"]["id"]
    appSubscriptionStatus = subscription_extended["appSubscription"]["status"]
    appTrialDays = subscription_extended["appSubscription"]["trialDays"]
    { success: true, appSubscriptionId: appSubscriptionId, appSubscriptionStatus: appSubscriptionStatus, appTrialDays: appTrialDays, status_code: 200 }
  end
end
