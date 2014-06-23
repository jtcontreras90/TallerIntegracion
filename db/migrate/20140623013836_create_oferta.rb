class CreateOferta < ActiveRecord::Migration
  def change
    create_table :oferta do |t|
      t.string :sku
      t.integer :precio
      t.datetime :fecha_inicio
      t.datetime :fecha_termino
      t.boolean :publicado

      t.timestamps
    end
  end
end
