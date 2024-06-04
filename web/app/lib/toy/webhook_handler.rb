# frozen_string_literal: true

module Toy
  # WebhookHandler is the base handler for the application.
  module WebhookHandler
    extend ShopifyAPI::Webhooks::WebhookHandler

    class << self
      def handle(data: nil)
        return if data.nil?

        topic = data.topic
        job_class_name = [ ShopifyApp.configuration.webhook_jobs_namespace, "#{topic}_job" ].compact.join("/").classify

        if (job_class = job_class_name.safe_constantize)
          job_class.handle(topic: topic, shop: data.shop, body: data.body)
        else
          Rails.logger.warn("[#{self.class}] - Line #{__LINE__}: in WebhookHandler#handle. No job class found for topic: #{topic}")
        end
      end
    end
  end
end
