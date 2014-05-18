class AddPedidoRefToVenta < ActiveRecord::Migration
  def change
    add_reference :venta, :pedido, index: true
  end
end
