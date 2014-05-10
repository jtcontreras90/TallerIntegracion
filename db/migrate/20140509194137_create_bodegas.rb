class CreateBodegas < ActiveRecord::Migration
  def change
    create_table :bodegas do |t|
      t.string :name
      t.string :password
      t.string :url

      t.timestamps
    end
  end
end
