# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_06_09_193325) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "shops", force: :cascade do |t|
    t.string "shopify_domain", null: false
    t.string "shopify_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "access_scopes", default: "", null: false
    t.index ["shopify_domain"], name: "index_shops_on_shopify_domain", unique: true
  end

  create_table "subscription_line_items", primary_key: "line_item_id", id: :string, force: :cascade do |t|
    t.string "subscription_id", null: false
    t.string "interval"
    t.decimal "price_amount"
    t.string "price_currency_code"
    t.string "terms"
    t.decimal "balance_used_amount"
    t.string "balance_used_currency_code"
    t.decimal "capped_amount"
    t.string "capped_amount_currency_code"
    t.integer "discount_duration_limit_in_intervals"
    t.integer "discount_remaining_duration_in_intervals"
    t.decimal "discount_price_after_discount_amount"
    t.string "discount_price_after_discount_currency_code"
    t.decimal "discount_value_amount"
    t.string "discount_value_currency_code"
    t.decimal "discount_percentage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["line_item_id"], name: "index_subscription_line_items_on_line_item_id", unique: true
    t.index ["subscription_id"], name: "index_subscription_line_items_on_subscription_id"
  end

  create_table "subscriptions", primary_key: "subscription_id", id: :string, force: :cascade do |t|
    t.string "name"
    t.string "status"
    t.datetime "current_period_end"
    t.string "return_url"
    t.boolean "test"
    t.integer "trial_days"
    t.datetime "subscription_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subscription_id"], name: "index_subscriptions_on_subscription_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.bigint "shopify_user_id", null: false
    t.string "shopify_domain", null: false
    t.string "shopify_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "access_scopes", default: "", null: false
    t.datetime "expires_at"
    t.index ["shopify_user_id"], name: "index_users_on_shopify_user_id", unique: true
  end

  add_foreign_key "subscription_line_items", "subscriptions", primary_key: "subscription_id"
end
