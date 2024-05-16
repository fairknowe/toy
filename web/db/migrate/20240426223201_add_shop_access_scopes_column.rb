class AddShopAccessScopesColumn < ActiveRecord::Migration[7.1]
  def change
    add_column :shops, :access_scopes, :string, default: "", null: false
  end
end
