class RemoveCantidadFromVentas < ActiveRecord::Migration
  def change
    remove_column :venta, :cantidad, :integer
  end
end
