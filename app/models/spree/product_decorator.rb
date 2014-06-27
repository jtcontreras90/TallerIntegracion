Spree::Product.class_eval do
  def refreshAttributes
  	puts "-------------------------------------------------"
  	minPrice=[self.validInternetPrice, self.precioOferta, self.precioPricing].min
  	puts "precio: #{minPrice}"
  	self.price=minPrice
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

  def precioOferta
  	p=1000000000
  	ofertas=Oferta.where('sku = ? AND fecha_inicio < ? AND fecha_termino > ?', self.sku, DateTime.now, DateTime.now).order('precio asc')
  	if ofertas.count > 0
  		p=ofertas[0].precio
  	end
  	p
  end

  def precioPricing
  	p=1000000000
  	#Si el precio es 0 se considera como válido considerar el precio Pricing
  	if self.internet_price==0
  		pricing=Pricing.findBySKU(self.sku)
	  	if pricing
	  		p=pricing.precio
	  	end
  	end
  	p
  end

  def tieneOferta
  	Oferta.where('sku = ? AND fecha_inicio < ? AND fecha_termino > ?', self.sku, DateTime.now, DateTime.now).count > 0
  end

  def validInternetPrice
  	p=1000000000
  	#Si el precio es 0 se considera inválido y se obtiene el precio por otro medio
  	if self.internet_price>0
  		p=self.internet_price
  	end
  	p
  end

end