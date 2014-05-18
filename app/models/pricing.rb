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
	 	puts Pricing.where("sku like ? and fecha_actualizacion <= ? and fecha_vigencia > ?","%#{sku}%",DateTime.now,DateTime.now)[0].precio
			return Pricing.where("sku like ? and fecha_actualizacion <= ? and fecha_vigencia > ?","%#{sku}%",DateTime.now,DateTime.now)
	 end

end
