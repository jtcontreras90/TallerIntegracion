class AddEnviadoToPedidos < ActiveRecord::Migration
  def change
    add_column :pedidos, :enviado, :boolean
  end
end
