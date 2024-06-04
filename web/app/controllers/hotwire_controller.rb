# frozen_string_literal: true

class HotwireController < ApplicationController
    def update
        Rails.logger.info("[#{self.class}] - Line #{__LINE__}: in HotwireController#add. params: #{params}")
        shop_domain = params[:shop_domain]
        shop = Shop.find_by(shopify_domain: shop_domain)

        if shop.nil?
            Rails.logger.error("#{self.class} failed: cannot find shop with domain '#{shop_domain}'")
            return
        end
        stream_name = "toy-#{shop_domain}"
        shop.broadcast_action_to(
          stream_name,
          action: :update,
          target: "hotwire-test",
          # locals: { dashboard_records: },
          partial: "home/partials/content",
        )

        render(json: { message: "success" }, status: :ok)
    end

    def close
        Rails.logger.info("[#{self.class}] - Line #{__LINE__}: in HotwireController#close. params: #{params}")
        shop_domain = params[:shop_domain]
        shop = Shop.find_by(shopify_domain: shop_domain)

        if shop.nil?
            Rails.logger.error("#{self.class} failed: cannot find shop with domain '#{shop_domain}'")
            return
        end
        stream_name = "toy-#{shop_domain}"
        shop.broadcast_action_to(
          stream_name,
          action: :replace,
          target: "hotwire-test",
          html: "<div id='hotwire-test'></div>",
        )

        render(json: { message: "success" }, status: :ok)
    end
end
