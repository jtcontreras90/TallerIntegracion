class RemoveRutClienteFromVentas < ActiveRecord::Migration
  def change
    remove_column :venta, :rutCliente, :string
  end
end
