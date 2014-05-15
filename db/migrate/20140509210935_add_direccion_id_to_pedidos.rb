class AddDireccionIdToPedidos < ActiveRecord::Migration
  def change
    add_column :pedidos, :direccionID, :integer
  end
end
