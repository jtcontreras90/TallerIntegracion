class AddDireccionToPedidos < ActiveRecord::Migration
  def change
    add_column :pedidos, :direccion, :string
    add_column :pedidos, :cant_vendida, :integer
    add_column :pedidos, :cant_quebrada, :integer
  end
end
