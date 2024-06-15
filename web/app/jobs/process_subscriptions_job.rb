# frozen_string_literal: true

class ProcessSubscriptionsJob < ApplicationJob
  queue_as :default
  def perform(shop_domain, subscription_data)
    Subscription.transaction do
        begin
          subscription = Subscription.find_or_initialize_by(subscription_id: subscription_data["id"])
          subscription.assign_attributes(
            shopify_domain: shop_domain,
            name: subscription_data["name"],
            status: subscription_data["status"],
            current_period_end: subscription_data["currentPeriodEnd"],
            return_url: subscription_data["returnUrl"],
            test: subscription_data["test"],
            trial_days: subscription_data["trialDays"],
            subscription_created_at: subscription_data["createdAt"],
          )
          subscription.save!

          unless subscription_data["lineItems"].nil? || subscription_data["lineItems"].empty?


          line_item_ids = subscription_data["lineItems"].map { |li| li["id"] }
          existing_line_items = SubscriptionLineItem.where(line_item_id: line_item_ids).index_by(&:line_item_id)

          subscription_data["lineItems"].each do |line_item_data|
            begin
              subscription_line_item = existing_line_items[line_item_data["id"]] || SubscriptionLineItem.new(line_item_id: line_item_data["id"])
              subscription_line_item.assign_attributes(
                subscription_id: subscription.subscription_id, # Ensure the correct assignment
                interval: line_item_data.dig("plan", "pricingDetails", "interval"),
                price_amount: line_item_data.dig("plan", "pricingDetails", "price", "amount"),
                price_currency_code: line_item_data.dig("plan", "pricingDetails", "price", "currencyCode"),
                terms: line_item_data.dig("plan", "pricingDetails", "terms"),
                balance_used_amount: line_item_data.dig("plan", "pricingDetails", "balanceUsed", "amount"),
                balance_used_currency_code: line_item_data.dig("plan", "pricingDetails", "balanceUsed", "currencyCode"),
                capped_amount: line_item_data.dig("plan", "pricingDetails", "cappedAmount", "amount"),
                capped_amount_currency_code: line_item_data.dig("plan", "pricingDetails", "cappedAmount", "currencyCode"),
                discount_duration_limit_in_intervals: line_item_data.dig("plan", "pricingDetails", "discount", "durationLimitInIntervals"),
                discount_remaining_duration_in_intervals: line_item_data.dig("plan", "pricingDetails", "discount", "remainingDurationInIntervals"),
                discount_price_after_discount_amount: line_item_data.dig("plan", "pricingDetails", "discount", "priceAfterDiscount", "amount"),
                discount_price_after_discount_currency_code: line_item_data.dig("plan", "pricingDetails", "discount", "priceAfterDiscount", "currencyCode"),
                discount_value_amount: line_item_data.dig("plan", "pricingDetails", "discount", "value", "amount", "amount"),
                discount_value_currency_code: line_item_data.dig("plan", "pricingDetails", "discount", "value", "amount", "currencyCode"),
                discount_percentage: line_item_data.dig("plan", "pricingDetails", "discount", "value", "percentage"),
              )
              subscription_line_item.save!
            rescue StandardError => e
              Rails.logger.error("Line #{__LINE__}: in ProcessSubscriptionsJob. Error processing line item #{line_item_data["line_item_id"]}: #{e.message}")
              next
            end
          end
          end
        rescue StandardError => e
          Rails.logger.error("Line #{__LINE__}: in ProcessSubscriptionsJob. Error processing subscription #{subscription_data["subscription_id"]}: #{e.message}")
          next
        end
      end
  end
end
