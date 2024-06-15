# frozen_string_literal: true

class ProductsCreateJob < ActiveJob::Base
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

    Rails.logger.info("Line #{__LINE__}: in ProductsCreateJob. Shop '#{shop_domain}', webhook: #{webhook.inspect}")
    Rails.logger.info("Line #{__LINE__}: in ProductsCreateJob. TODO: Add code to process the webhook data")

  rescue StandardError => e
    Rails.logger.error("Line #{__LINE__}: in ProductsCreateJob. Error: #{e.message}")
  end
end
