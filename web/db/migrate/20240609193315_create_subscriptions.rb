class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions, id: false do |t|
      t.string :subscription_id, null: false, primary_key: true
      t.string :name
      t.string :status
      t.datetime :current_period_end
      t.string :return_url
      t.boolean :test
      t.integer :trial_days
      t.datetime :subscription_created_at

      t.timestamps
    end
    add_index :subscriptions, :subscription_id, unique: true
  end
end
