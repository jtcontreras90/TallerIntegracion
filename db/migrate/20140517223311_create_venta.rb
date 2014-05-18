class CreateVenta < ActiveRecord::Migration
  def change
    create_table :venta do |t|
      t.integer :utilidad
      t.integer :ingreso
      t.integer :cantidad
      t.string :rutCliente
      t.string :sku
      t.datetime :fecha
      t.references :spree_variant
      t.timestamps
    end
  end
end
