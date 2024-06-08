# frozen_string_literal: true

class AppInstallation < ApplicationService
    APP_INSTALLATION_QUERY = <<~QUERY
      query currentAppInstallation {
        appInstallation {
          id
          launchUrl
          app {
            id
            handle
            description
            privacyPolicyUrl
            apiKey
            appStoreAppUrl
            appStoreDeveloperUrl
            developerName
            developerType
            previouslyInstalled
            pricingDetails
            pricingDetailsSummary
            publicCategory
            published
            features
            installation {
              id
              launchUrl
              uninstallUrl
            }
            uninstallMessage
            failedRequirements {
              message
            }
            embedded
            webhookApiVersion
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
    client = ShopifyAPI::Clients::Graphql::Admin.new(session: @session)
      response = client.query(
        query: APP_INSTALLATION_QUERY,
      )
      Rails.logger.info("[#{self.class}] - Line #{__LINE__}: in appInstallation#call, response: #{response.inspect}")
      process_response(response)
  end

  private

  def process_response(response)
    appInstallation = response.body.dig("data", "appInstallation")
    if appInstallation.nil?
      { success: false, queryError: "No app installation information is available", status_code: 200, shop_domain: @shop_domain }
    elsif appInstallation.is_a?(Hash)
        return { success: false, queryError: "No app installation information is available", status_code: 200, shop_domain: @shop_domain } if appInstallation.empty?

      Rails.logger.info("[#{self.class}] - Line #{__LINE__}: in appInstallation#call, activeSubscriptions: #{activeSubscriptions.inspect}")
      { success: true, appInstallation: appInstallation, status_code: 200, shop_domain: @shop_domain }
    else
      Rails.logger.warn("[#{self.class}] - Line #{__LINE__}: in appInstallation#process_response. appInstallation is of type #{appInstallation.class}.")
    end
  end
end
