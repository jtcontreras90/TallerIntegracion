class AddSalePriceToSpreeProducts < ActiveRecord::Migration
  def change
    add_column :spree_products, :normal_price, :integer
  end
end
