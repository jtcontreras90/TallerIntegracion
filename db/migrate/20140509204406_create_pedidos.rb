class CreatePedidos < ActiveRecord::Migration
  def change
    create_table :pedidos do |t|
      t.datetime :fecha
      t.string :rut
      t.date :fechaLimite
      t.string :sku
      t.float :cantidad
      t.string :unidad

      t.timestamps
    end
  end
end