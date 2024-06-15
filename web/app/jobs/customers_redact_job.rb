# frozen_string_literal: true

class CustomersRedactJob < ActiveJob::Base
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

    shop.with_shopify_session do
      Rails.logger.info("#{self.class} Delete customer data for shop '#{shop_domain}'")
    end
  end
end
