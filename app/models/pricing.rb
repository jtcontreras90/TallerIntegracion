class Pricing < ActiveRecord::Base
	
	 def self.findBySKU(sku)

	 	p=Pricing.where("sku like ? and fecha_actualizacion <= ? and fecha_vigencia > ?","%#{sku}%",DateTime.now,DateTime.now)
	 	if p
	 		return p.inspect
	 	else
	 		return p
	 	end
	 end

	 def self.findById(id)
	 	p= Pricing.where("id_pricing = ? and fecha_actualizacion <= ? and fecha_vigencia > ?",id,DateTime.now,DateTime.now)
	 	if p
	 		puts p.inspect
	 		return p.inspect
	 	else
	 		return p
	 	end
	 end

	 def self.precioBySKU(sku)
	 	p=Pricing.where("sku like ? and fecha_actualizacion <= ? and fecha_vigencia > ?","%#{sku}%",DateTime.now,DateTime.now)
	 	if p.count > 0
	 		precio=p[0].precio
	 		puts precio
			return precio
		else
			return Spree::Variant.where(sku: sku).first.product.normal_price
		end
	 end

	 def self.precioTransferenciaBySKU(sku)
	 	p = Pricing.where("sku like ? and fecha_actualizacion <= ? and fecha_vigencia > ?","%#{sku}%",DateTime.now,DateTime.now).first
	 	if p
	 		costo= p.costo_traspaso
		 	puts costo
			return costo
		else
			return 0
		end
	 end

end
