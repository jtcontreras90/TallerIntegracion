class Bodega < ActiveRecord::Base

	has_many :transferencias

	require 'json'

	def self.find_by_username(username)
		Bodega.where(name: username).first
	end

	def self.enviarProducto
		Transferencia.where(sent: false).each do |t|
			enviado=ApiBodega.despacharOtrasBodegas(t.almacenId,t.sku,t.cantidad) #Despachar a almacenId
			t.sent=true
			t.save
		end
	end

	def self.pedirProducto
		
	end
end
