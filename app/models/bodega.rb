class Bodega < ActiveRecord::Base

	require 'json'

	def self.find_by_username(username)
		Bodega.where(name: username).first
	end

	def enviarProducto
	end

	def pedirProducto
		
	end
end
