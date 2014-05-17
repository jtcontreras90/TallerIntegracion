require 'mongoid'

class Quiebre
	include Mongoid::Document
	store_in collection: "quiebres", database: "datawarehouse", session: "default"
	field :fecha, type: DateTime
	field :sku_producto, type: Integer
	field :rut_cliente, type: String

	def self.agregar(fecha, sku, rut)
		Quiebre.create(fecha: fecha, sku_producto: sku, rut_cliente: rut)
	end

	def self.query
		Quiebre.all.each do |quiebre|
  			puts quiebre.inspect
		end

	
	end
end
