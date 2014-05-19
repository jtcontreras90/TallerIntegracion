class Pricing < ActiveRecord::Base
	
	 def self.findBySKU(sku)
	 	puts Pricing.where("sku like ? and fecha_actualizacion <= ? and fecha_vigencia > ?","%#{sku}%",DateTime.now,DateTime.now).inspect
	 	return Pricing.where("sku like ? and fecha_actualizacion <= ? and fecha_vigencia > ?","%#{sku}%",DateTime.now,DateTime.now).inspect
	 end

	 def self.findById(id)
	 	puts Pricing.where("id_pricing = ? and fecha_actualizacion <= ? and fecha_vigencia > ?",id,DateTime.now,DateTime.now).inspect
	 	return Pricing.where("id_pricing = ? and fecha_actualizacion <= ? and fecha_vigencia > ?",id,DateTime.now,DateTime.now).inspect
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
	 	costo = Pricing.where("sku like ? and fecha_actualizacion <= ? and fecha_vigencia > ?","%#{sku}%",DateTime.now,DateTime.now)[0].costo_traspaso
	 	puts costo
		return costo
	 	
	 end

end
