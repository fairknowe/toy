# frozen_string_literal: true

class ProductsCount < ApplicationService

    RETRIEVE_PRODUCTS_COUNT = <<~QUERY
    {
    productsCount {
        count
    }
    }
    QUERY

    def initialize(session:)
        super()
        @session = session
    end

    def call
        client = ShopifyAPI::Clients::Graphql::Admin.new(session: @session)
        # Rails.logger.info "[#{self.class}] - Line #{__LINE__}: in ProductsCount#call, client: #{client}"

        begin
            response = client.query(
                query: RETRIEVE_PRODUCTS_COUNT
            )
        rescue => e
            Rails.logger.error "[#{self.class}] - Line #{__LINE__}: in ProductsCount#call, error: #{e.message}"
            return e.message
        end

        if response.present?
            product_count = response.body["data"]["productsCount"]
            # Rails.logger.info "[#{self.class}] - Line #{__LINE__}: in ProductsCount#call, product_count: #{product_count}"
            product_count
        else
            Rails.logger.error "[#{self.class}] - Line #{__LINE__}: in ProductsCount#call, response.errors: #{response.errors}"
            return response
        end
    end
end
