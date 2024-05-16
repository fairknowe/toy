# frozen_string_literal: true

class EnvironmentController < AuthenticatedController

  # GET /api/environment
  def index
    Rails.logger.info "[#{self.class}] - Line #{__LINE__}: in EnvironmentController#index. params: #{params}"
    Rails.logger.info "[#{self.class}] - Line #{__LINE__}: apiKey: #{ShopifyApp.configuration.api_key}"
    render(json: {apiKey: ShopifyApp.configuration.api_key})

    # shopify_user_id = current_user_id # current_user_id is a method from AuthenticatedController
    # user = User.find_by(shopify_user_id: shopify_user_id)
    # Rails.logger.info "[#{self.class}] - Line #{__LINE__}: in EnvironmentController#index. user: #{user.inspect}"
    # render(json: {user: user.attributes})
  end
end
