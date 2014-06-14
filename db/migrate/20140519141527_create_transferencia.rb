class CreateTransferencia < ActiveRecord::Migration
  def change
    create_table :transferencia do |t|
      t.string :almacenId
      t.string :sku
      t.integer :cantidad
      t.integer :costotransferencia
      t.boolean :sent
      t.references :bodega

      t.timestamps
    end
  end
end
