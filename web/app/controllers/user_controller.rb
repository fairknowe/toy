# frozen_string_literal: true

class UserController < AuthenticatedController

  # GET /api/current/user
  def current
    Rails.logger.info "[#{self.class}] - Line #{__LINE__}: in UsersController#current. params: #{params}"

    shopify_user_id = current_user_id # current_user_id is a method from AuthenticatedController
    Rails.logger.info "[#{self.class}] - Line #{__LINE__}: in UsersController#current. shopify_user_id: #{shopify_user_id}"
    user = User.find_by(shopify_user_id: shopify_user_id)
    Rails.logger.info "[#{self.class}] - Line #{__LINE__}: in UsersController#current. user: #{user.inspect}"
    render(json: {user: user.attributes})
  end

  def modal
    Rails.logger.info "[#{self.class}] - Line #{__LINE__}: in UsersController#modal. params: #{params}"
    render partial: 'user/modal', layout: false
  end

end
