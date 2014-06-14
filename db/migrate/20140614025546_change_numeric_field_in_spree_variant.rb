class ChangeNumericFieldInSpreeVariant < ActiveRecord::Migration
  def self.up
  	change_column :spree_variants, :cost_price, :decimal, :precision => 14, :scale => 2
  	change_column :spree_prices, :amount, :decimal, :precision => 14, :scale => 2
  end

  def self.down
  	change_column :spree_variants, :cost_price, :decimal, :precision => 8, :scale => 2
  	change_column :spree_prices, :amount, :decimal, :precision => 8, :scale => 2
  end
end
