class CreateReservas < ActiveRecord::Migration
  def change
    create_table :reservas do |t|

      t.timestamps
    end
  end
end
