class AddQuebradoToPedidos < ActiveRecord::Migration
  def change
    add_column :pedidos, :quebrado, :boolean
  end
end
