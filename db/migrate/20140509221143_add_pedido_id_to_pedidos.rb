class AddPedidoIdToPedidos < ActiveRecord::Migration
  def change
    add_column :pedidos, :pedidoID, :integer
  end
end
