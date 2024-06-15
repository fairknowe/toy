# frozen_string_literal: true

# AppWebhooksController handles Shopify webhooks.

class AppWebhooksController < ActionController::Base
  include ShopifyApp::WebhookVerification

  def receive
    request_headers_hash = request.headers.to_h
    shopify_domain = request_headers_hash["HTTP_X_SHOPIFY_SHOP_DOMAIN"]
    api_version = request_headers_hash["HTTP_X_SHOPIFY_API_VERSION"]
    webhook_id = request_headers_hash["HTTP_X_SHOPIFY_WEBHOOK_ID"]
    topic = request_headers_hash["HTTP_X_SHOPIFY_TOPIC"]
    body_params = JSON.parse(request.raw_post) if request.raw_post.present?
    data = ShopifyAPI::Webhooks::WebhookMetadata.new(
      topic: topic,
      shop: shopify_domain,
      body: body_params || {},
      api_version: api_version,
      webhook_id: webhook_id,
      )

    Toy::WebhookHandler.handle(data:)
    head(:ok)
  end
end
