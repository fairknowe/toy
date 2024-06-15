# frozen_string_literal: true

class AppSubscriptionsUpdateJob < ActiveJob::Base
  extend ShopifyAPI::Webhooks::WebhookHandler

  class << self
    def handle(topic:, shop:, body:)
      perform_later(topic: topic, shop_domain: shop, webhook: body)
    end
  end

  def perform(topic:, shop_domain:, webhook:)
    shop = Shop.find_by(shopify_domain: shop_domain)

    if shop.nil?
      Rails.logger.error("#{self.class} failed: cannot find shop with domain '#{shop_domain}'")
      return
    end

    Rails.logger.info("Line #{__LINE__}: in AppSubscriptionsUpdateJob. Shop '#{shop_domain}', webhook: #{webhook.inspect}")
    app_subscription = webhook["app_subscription"]
    subscription_data = {
      "id" => app_subscription["admin_graphql_api_id"],
      "name" => app_subscription["name"],
      "status" => app_subscription["status"],
      "currency" => app_subscription["currency"],
      "capped_amount" => app_subscription["capped_amount"],
    }
    ProcessSubscriptionsJob.perform_later(shop_domain, subscription_data)

  rescue StandardError => e
    Rails.logger.error("Line #{__LINE__}: in AppSubscriptionsUpdateJob. Error: #{e.message}")
  end
end
