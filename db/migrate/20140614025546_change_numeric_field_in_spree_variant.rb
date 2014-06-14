class ChangeNumericFieldInSpreeVariant < ActiveRecord::Migration
  def change
  	change_column :spree_variants, :cost_price, :decimal, :precision => 14, :scale => 2
  end
end
