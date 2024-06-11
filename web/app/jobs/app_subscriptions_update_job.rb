# frozen_string_literal: true

class AppSubscriptionsUpdateJob < ActiveJob::Base
  extend ShopifyAPI::Webhooks::Handler

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
    Rails.logger.info("Line #{__LINE__}: in AppSubscriptionsUpdateJob. TODO: Add code to process the webhook data")
    # TODO: Add code to process the webhook data
    # ProcessSubscriptionsJob.perform_later(activeSubscriptions)

  rescue StandardError => e
    Rails.logger.error("Line #{__LINE__}: in AppSubscriptionsUpdateJob. Error: #{e.message}")
  end
end
