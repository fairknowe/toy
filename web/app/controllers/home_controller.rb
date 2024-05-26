# frozen_string_literal: true

class HomeController < ApplicationController
  include ShopifyApp::EmbeddedApp
  include ShopifyApp::EnsureInstalled
  include ShopifyApp::ShopAccessScopesVerification

  rescue_from JWT::ExpiredSignature do |exception|
    Rails.logger.error("[#{self.class}] - Line #{__LINE__}: JWT expired - #{exception.message}")
    redirect_to("/error.html") and return
  end

  def index
    begin
      decoded_id_token = JWT.decode(params[:id_token], ENV.fetch("SHOPIFY_API_SECRET"), true, algorithm: "HS256")
      payload = decoded_id_token[0]
      client_id = payload["aud"]

      shop_domain = payload["dest"].split("/").last
      shopify_user_id = payload["sub"]
      Rails.logger.info("[#{self.class}] - Line #{__LINE__}: in HomeController#index. shopify_user_id: #{shopify_user_id}")
    rescue JWT::DecodeError => e
      Rails.logger.error("[#{self.class}] - Line #{__LINE__}: Error decoding JWT - #{e.message}")
      redirect_to("/error.html") and return
    end

    if ShopifyAPI::Context.embedded? && (!params[:embedded].present? || params[:embedded] != "1")
      redirect_to(ShopifyAPI::Auth.embedded_app_url(params[:host]), allow_other_host: true)
    else
      params.permit(:shop, :host)
      @shop_origin = params[:shop]
      @host = params[:host]
      Rails.logger.info("[#{self.class}] - Line #{__LINE__}: in HomeController#index. shop_origin: #{@shop_origin}, host: #{@host}")
    end
  end
end
