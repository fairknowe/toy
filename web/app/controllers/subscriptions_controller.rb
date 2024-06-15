# frozen_string_literal: true

class SubscriptionsController < AuthenticatedController
  def create
    response = SubscriptionCreate.call(session: current_shopify_session)
    Rails.logger.info("[#{self.class}] - Line #{__LINE__}: in SubscriptionsController#create, response: #{response}")
    if response[:success]
      render(json: { success: response[:success], appSubscriptionId: response[:appSubscriptionId], confirmationUrl: response[:confirmationUrl], status: response[:status_code] })
    else
      render(json: { success: response[:success], queryError: response[:queryError] }, status: response[:status_code])
    end
  rescue => e
    Rails.logger.error("Failed to create subscription: #{e.message}")
    render(json: { success: false, queryError: e.message }, status: 200)
  end

  def cancel
    response = SubscriptionCancel.call(session: current_shopify_session)
    Rails.logger.info("[#{self.class}] - Line #{__LINE__}: in SubscriptionsController#cancel, response: #{response}")
    if response[:success]
      render(json: { success: response[:success], appSubscriptionId: response[:appSubscriptionId], appSubscriptionStatus: response[:appSubscriptionStatus], status: response[:status_code] })
    else
      render(json: { success: response[:success], queryError: response[:queryError] }, status: response[:status_code])
    end
  rescue => e
    Rails.logger.error("Failed to create subscription: #{e.message}")
    render(json: { success: false, queryError: e.message }, status: 200)
  end

  def extend
    response = SubscriptionExtendTrial.call(session: current_shopify_session)
    Rails.logger.info("[#{self.class}] - Line #{__LINE__}: in SubscriptionsController#extend, response: #{response}")
    if response[:success]
      render(json: { success: response[:success], appSubscriptionId: response[:appSubscriptionId], appSubscriptionStatus: response[:appSubscriptionStatus], appTrialDays: response[:appTrialDays], status: response[:status_code] })
    else
      render(json: { success: response[:success], queryError: response[:queryError] }, status: response[:status_code])
    end
  rescue => e
    Rails.logger.error("Failed to extend subscription: #{e.message}")
    render(json: { success: false, queryError: e.message }, status: 200)
  end

  # GET /api/subscriptions/status
  def status
    shop_domain = params[:shop_domain]
    response = SubscriptionStatus.call(session: current_shopify_session)
    # { success: false, queryError: queryError, status_code: 200 }
    # { success: true, activeSubscriptions: activeSubscriptions, status_code: 200 }
    Rails.logger.info("[#{self.class}] - Line #{__LINE__}: in SubscriptionsController#status, response: #{response}")
    if response[:success] && shop_domain == response[:shop_domain]
      # TODO: db add/update here with response[:activeSubscriptions]
      render(json: { success: response[:success], activeSubscriptions: response[:activeSubscriptions] }, status: response[:status_code])
    else
      render(json: { success: response[:success], queryError: response[:queryError] }, status: response[:status_code])
    end
  rescue => e
    Rails.logger.error("Failed to get subscription status status: #{e.message}")
    render(json: { success: false, queryError: e.message }, status: 200)
  end
end
