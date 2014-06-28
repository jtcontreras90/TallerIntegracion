class CreateEOrders < ActiveRecord::Migration
  def change
    create_table :e_orders do |t|
      t.string :sku
      t.integer :cantidad
      t.string :direccion
      t.integer :precio
      t.string :pedidoID
      t.boolean :enviado
      t.integer :order_id

      t.timestamps
    end
  end
end
