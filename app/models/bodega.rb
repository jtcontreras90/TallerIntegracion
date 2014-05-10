class Bodega < ActiveRecord::Base


	def self.find_by_username(username)
		Bodega.where(name: username).first
	end

	def enviarProducto
	end

	def pedirProducto
		
	end
end
