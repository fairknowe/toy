# frozen_string_literal: true

class AuthenticatedController < ApplicationController
  include ShopifyApp::EnsureHasSession

  helper_method :current_user_id

  def current_user_id
    Rails.logger.info("[#{self.class}] - Line #{__LINE__}: in AuthenticatedController#current_user_id. current_shopify_session scope: #{current_shopify_session.scope}")
    associated_user = current_shopify_session.associated_user
    return unless associated_user

    @user_id = associated_user.id
    Rails.logger.info("[#{self.class}] - Line #{__LINE__}: in AuthenticatedController#current_user_id. user_id: #{@user_id}")
    Rails.logger.info("[#{self.class}] - Line #{__LINE__}: in AuthenticatedController#current_user_id. associated_user_scope: #{current_shopify_session.associated_user_scope}")
    @user_id
  end
end
