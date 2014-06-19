class AddInternetSalePriceToSpreeProducts < ActiveRecord::Migration
  def self.up
  	add_column :spree_products, :internet_price, :integer

  	Spree::Product.all.each do |p|
  		p.internet_price=p.price
  		p.save
  	end
  end

  def self.down
  	remove_column :spree_products, :internet_price
  end
end
