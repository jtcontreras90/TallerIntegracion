class CreatePricings < ActiveRecord::Migration
  def change
    create_table :pricings do |t|
      t.integer :precio
      t.date :fecha_actualizacion
      t.date :fecha_vigencia
      t.integer :costo_producto
      t.integer :costo_traspaso
      t.integer :costo_almacenaje
      t.string :sku
      t.integer :id_pricing

      t.timestamps
    end
  end
end
