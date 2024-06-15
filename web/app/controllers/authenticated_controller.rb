# frozen_string_literal: true

class AuthenticatedController < ApplicationController
  include ShopifyApp::EnsureHasSession

  helper_method :current_user_id

  def current_user_id
    associated_user = current_shopify_session.associated_user
    return unless associated_user

    @user_id = associated_user.id
    @user_id
  end
end
