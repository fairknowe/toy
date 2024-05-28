# frozen_string_literal: true

class AppUninstalledJob < ActiveJob::Base
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

    Rails.logger.info("[#{self.class}] - Line #{__LINE__}: in AppUninstalledJob. Deleting shop '#{shop_domain}' and associated users")

    ActiveRecord::Base.transaction do
      User.where(shopify_domain: shop_domain).destroy_all
      shop.destroy!
    end

    Rails.logger.info("[#{self.class}] - Line #{__LINE__}: in AppUninstalledJob. Successfully deleted shop '#{shop_domain}' and associated users")
  rescue StandardError => e
    Rails.logger.error("[#{self.class}] - Line #{__LINE__}: in AppUninstalledJob. Error deleting shop '#{shop_domain}' and associated users: #{e.message}")
    raise
  end
end
