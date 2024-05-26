# frozen_string_literal: true

module Toy
  # WebhookHandler is the base handler for the application.
  module WebhookHandler
  extend ShopifyAPI::Webhooks::WebhookHandler

    class << self
      # include Toy::SignalMethods
      def handle(data: nil)
        # Rails.logger.info "[#{self.class}] - Line #{__LINE__}: in WebhookHandler#handle. Received webhook! topic: #{data.topic} shop: #{data.shop} webhook_id: #{data.webhook_id} api_version: #{data.api_version} body: #{data.body}"
      end
      # def handle(topic:, shop:, body:)
      #   Rails.logger.info "[#{self.class}] - Line #{__LINE__}: in WebhookHandler#handle. topic: #{topic}, shop: #{shop}, body: #{body}"
      #   params_hash = JSON.parse(body)
      #   params_hash["shopify_domain"] = shop
      #   params_hash["topic"] = topic.gsub("/", "_")
      #   score = WEBHOOK_PRIORITY[params_hash["topic"]]
      #   params_json = JSON.generate(params_hash)
      #   if score < 6
      #     add_to_webhook_priority_queue(score, params_json)
      #   else
      #     add_to_webhook_standard_queue(score, params_json)
      #   end
      # end
    end
  end
end
