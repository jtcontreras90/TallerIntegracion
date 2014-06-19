Spree::Product.class_eval do
  def refreshAttributes
	  	if rand(0..1)==1
	  		self.price=rand(0..100000000)
	  	else
	  		self.price=self.internet_price
	  	end
	  	self.save
  end

end