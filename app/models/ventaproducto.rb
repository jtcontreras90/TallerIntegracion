require 'mongoid'

class Ventaproducto
	include Mongoid::Document
	store_in collection: "ventasXproducto", database: "datawarehouse", session: "default"
	field :utilidades, type: Integer
	field :ingresos, type: Integer
	field :cantidad_transada, type: Integer
	field :sku_producto, type: Integer
	field :fecha, type: Date

	def self.agregar(ut, ing, cant, sku, f)
		Ventaproducto.create(utilidades: ut, ingresos: ing, cantidad_transada: cant, sku_producto: sku, fecha: f)
	end

	def self.query
		Ventaproducto.all.each do |venta|
  			puts venta.inspect
		end

	
	end
end