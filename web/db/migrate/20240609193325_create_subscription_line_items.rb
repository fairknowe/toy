class CreateSubscriptionLineItems < ActiveRecord::Migration[7.1]
  def change
    create_table :subscription_line_items, id: false do |t|
      t.string :line_item_id, null: false, primary_key: true
      t.references :subscription, null: false, foreign_key: { to_table: :subscriptions, primary_key: :subscription_id }, type: :string

      # Pricing details
      t.string :interval
      t.decimal :price_amount
      t.string :price_currency_code
      t.string :terms
      t.decimal :balance_used_amount
      t.string :balance_used_currency_code
      t.decimal :capped_amount
      t.string :capped_amount_currency_code

      # Discount details
      t.integer :discount_duration_limit_in_intervals
      t.integer :discount_remaining_duration_in_intervals
      t.decimal :discount_price_after_discount_amount
      t.string :discount_price_after_discount_currency_code
      t.decimal :discount_value_amount
      t.string :discount_value_currency_code
      t.decimal :discount_percentage

      t.timestamps
    end
    add_index :subscription_line_items, :line_item_id, unique: true
  end
end
