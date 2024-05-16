# frozen_string_literal: true

class HomeController < ApplicationController
  include ShopifyApp::EmbeddedApp
  include ShopifyApp::EnsureInstalled
  include ShopifyApp::ShopAccessScopesVerification

  DEV_INDEX_PATH = Rails.root.join("frontend")
  PROD_INDEX_PATH = Rails.public_path.join("dist")

  rescue_from JWT::ExpiredSignature do |exception|
    Rails.logger.error("[#{self.class}] - Line #{__LINE__}: JWT expired - #{exception.message}")
    redirect_to("/") and return
  end

  def index
    # Rails.logger.info "[#{self.class}] - Line #{__LINE__}: in HomeController#index. params: #{params.inspect}"

    begin
      decoded_id_token = JWT.decode(params[:id_token], ENV.fetch("SHOPIFY_API_SECRET"), true, algorithm: "HS256")
      payload = decoded_id_token[0]
      # Rails.logger.info "[#{self.class}] - Line #{__LINE__}: in HomeController#index. JWT payload: #{payload.inspect}"
      client_id = payload["aud"]

      # Rails.logger.info "[#{self.class}] - Line #{__LINE__}: in HomeController#index. client_id (was shopify): #{client_id}"
      # # {"iss"=>"https://got-any-store.myshopify.com/admin", "dest"=>"https://got-any-store.myshopify.com", "aud"=>"736ef8a13f9a3ffe19cedfdbda326d88", "sub"=>"89301123315", "exp"=>1712869779, "nbf"=>1712869719, "iat"=>1712869719, "jti"=>"fe2ff832-0fbd-4f5d-8356-7586a294b709", "sid"=>"3d2bef2b-6dab-41f6-8305-dd63bae100b4", "sig"=>"fe4cb7e223dcaf0f017fd37f48a8107a942a8033fd99edc9f314ee998a1a7532"}
      shop_domain = payload["dest"].split("/").last
      shopify_user_id = payload["sub"]
      Rails.logger.info("[#{self.class}] - Line #{__LINE__}: in HomeController#index. shopify_user_id: #{shopify_user_id}")
    rescue JWT::DecodeError => e
      Rails.logger.error("[#{self.class}] - Line #{__LINE__}: Error decoding JWT - #{e.message}")
      redirect_to("/") and return
    end

    if ShopifyAPI::Context.embedded? && (!params[:embedded].present? || params[:embedded] != "1")
      redirect_to(ShopifyAPI::Auth.embedded_app_url(params[:host]), allow_other_host: true)
    else
      # Rails.logger.info "[#{self.class}] - Line #{__LINE__}: in HomeController#index. PROD_INDEX_PATH: #{PROD_INDEX_PATH}, DEV_INDEX_PATH: #{DEV_INDEX_PATH}"
      contents = File.read(File.join(Rails.env.production? ? PROD_INDEX_PATH : DEV_INDEX_PATH, "index.html"))
      render(plain: contents, content_type: "text/html", layout: false)
    end
  end
end
