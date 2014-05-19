class Bodega < ActiveRecord::Base

	has_many :transferencias

	require 'json'

	def self.find_by_username(username)
		Bodega.where(name: username).first
	end

	def self.enviarProducto
    	Rails.logger.info "[SCHEDULE][BODEGA.ENVIARPRODUCTO]Begin at #{Time.now}"
		Transferencia.where(sent: false).each do |t|
			enviado=ApiBodega.despacharOtrasBodegas(t.almacenId,t.sku,t.cantidad) #Despachar a almacenId
			t.sent=true
			t.save
		end
    	Rails.logger.info "[SCHEDULE][BODEGA.ENVIARPRODUCTO]Finish at #{Time.now}"
	end

	def self.pedirProducto
		
	end
end
