# frozen_string_literal: true

class UsersController < AuthenticatedController
  # GET /api/current/user
  def current
    shop_domain = params[:shop_domain]
    shopify_user_id = current_user_id # current_user_id is a method from AuthenticatedController
    user = User.find_by(shopify_user_id: shopify_user_id, shopify_domain: shop_domain)
    Rails.logger.info("[#{self.class}] - Line #{__LINE__}: in UsersController#current. user: #{user.inspect}")
    render(json: { user: user.attributes })
  end
end
