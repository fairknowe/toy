# frozen_string_literal: true

class ProductCreator < ApplicationService
  attr_reader :count

  CREATE_PRODUCTS_MUTATION = <<~QUERY
    mutation populateProduct($input: ProductInput!) {
      productCreate(input: $input) {
        product {
          title
          id
        }
      }
    }
  QUERY

  def initialize(count:, session:)
    super()
    @count = count
    @session = session
  end

  def call
    Rails.logger.info("[#{self.class}] - Line #{__LINE__}: in ProductCreator#call. session: #{@session.inspect}")
    client = ShopifyAPI::Clients::Graphql::Admin.new(session: @session)
    created_products = []

    (1..count).each do |_i|
      response = client.query(
        query: CREATE_PRODUCTS_MUTATION,
        variables: {
          input: {
            title: random_title,
          },
        },
      )

      Rails.logger.info("[#{self.class}] - Line #{__LINE__}: in ProductCreator#call, response.body: #{response.body}")

      return { success: false, error: response.body["errors"][0]["message"], status_code: 200 } if response.body["errors"].present?

      created_product = response.body.dig("data", "productCreate", "product")
      return { success: false, error: "Product creation failed", status_code: 500 } unless created_product

      created_products << created_product
      Rails.logger.info("[#{self.class}] - Line #{__LINE__}: in ProductCreator#call, created_product: #{created_product}")
    end

    { success: true, created_products: created_products, status_code: 200 }
  end

  private

  def random_title
    adjective = ADJECTIVES[rand(ADJECTIVES.size)]
    noun = NOUNS[rand(NOUNS.size)]

    "#{adjective} #{noun}"
  end

  def random_price
    (100.0 + rand(1000)) / 100
  end

  ADJECTIVES = [
    "autumn",
    "hidden",
    "bitter",
    "misty",
    "silent",
    "empty",
    "dry",
    "dark",
    "summer",
    "icy",
    "delicate",
    "quiet",
    "white",
    "cool",
    "spring",
    "winter",
    "patient",
    "twilight",
    "dawn",
    "crimson",
    "wispy",
    "weathered",
    "blue",
    "billowing",
    "broken",
    "cold",
    "damp",
    "falling",
    "frosty",
    "green",
    "long",
  ]

  NOUNS = [
    "waterfall",
    "river",
    "breeze",
    "moon",
    "rain",
    "wind",
    "sea",
    "morning",
    "snow",
    "lake",
    "sunset",
    "pine",
    "shadow",
    "leaf",
    "dawn",
    "glitter",
    "forest",
    "hill",
    "cloud",
    "meadow",
    "sun",
    "glade",
    "bird",
    "brook",
    "butterfly",
    "bush",
    "dew",
    "dust",
    "field",
    "fire",
    "flower",
  ]
end
