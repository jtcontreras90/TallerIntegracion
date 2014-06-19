Spree::Product.class_eval do
  def refreshAttributes
  	if rand(0..1)==1
  		self.price=rand(0..100000000)
  	else
  		self.price=self.internet_price
  	end
  	self.save
  end

  def refreshStock
	si=self.stock_items.first
	sku=self.sku
	stock=0
	begin
		stock=ApiBodega.obtenerStock sku
	rescue
	end
	puts "-------------------------------------------------"
	puts "stock: #{stock}"
	si['count_on_hand']=stock

	si.save
  end

end