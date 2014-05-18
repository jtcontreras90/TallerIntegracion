class RemoveSkuFromVentas < ActiveRecord::Migration
  def change
    remove_column :venta, :sku, :string
  end
end
