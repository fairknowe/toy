# frozen_string_literal: true

# AppWebhooksController handles Shopify webhooks.
# This code is created and owned by Fairknowe Inc. (FKI) All rights reserved
class AppWebhooksController < ActionController::Base
  include ShopifyApp::WebhookVerification

  def receive
    if params[:myshopify_domain].present? && params[:domain].present?
      Rails.logger.info("[#{self.class}] - Line #{__LINE__}: in AppWebhooksController#index. params: #{params}")
      # Parse and convert the body to a hash if it's passed as parameters
      body_params = params[:app_webhook].permit!.to_h if params[:app_webhook].present?
      data = ShopifyAPI::Webhooks::WebhookMetadata.new(
        topic: params["type"],
        shop: params["myshopify_domain"],
        body: body_params || {},
        api_version: ShopifyAPI::Context.api_version,
        webhook_id: params["id"].to_s,
        )
    Toy::WebhookHandler.handle(data:)
    end
    head(:ok)
  end
end
