# frozen_string_literal: true

class ProductsController < AuthenticatedController
  # GET /api/products/count
  def count
    product_count = ProductsCount.call(session: current_shopify_session)
    render(json: product_count)
  end

  # POST /api/products/create
  def create
    count = params.fetch(:count, 1) # Default to creating 1 product
    result = ProductCreator.call(count: count.to_i, session: current_shopify_session)

    if result[:success]
      render(json: { success: true, products: result[:created_products] }, status: result[:status_code] || 200)
    else
      render(json: { success: false, error: result[:error] }, status: result[:status_code] || 200)
    end
  rescue => e
    Rails.logger.error("Failed to create products: #{e.message}")
    render(json: { success: false, error: e.message }, status: 500, ok: false)
  end
end
