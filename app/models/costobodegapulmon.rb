require 'mongoid'

class Costobodegapulmon
	include Mongoid::Document
	store_in collection: "costosXbodegapulmon", database: "datawarehouse", session: "default"
	field :costo, type: Integer
	field :fecha, type: Date
	field :cantidad_productos, type: Integer

	def self.agregar(c, f, cant)
		Costobodegapulmon.create(costo: c, fecha: f, cantidad_productos: cant)
	end

	def self.query
		Costobodegapulmon.all.each do |costo|
  			puts costo.inspect
		end

	
	end
end