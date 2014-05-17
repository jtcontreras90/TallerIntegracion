require 'mongoid'

class Ventacliente
	include Mongoid::Document
	store_in collection: "ventasXcliente", database: "datawarehouse", session: "default"
	field :utilidades, type: Integer
	field :ingresos, type: Integer
	field :cantidad_pedidos, type: Integer
	field :rut_cliente, type: String
	field :fecha, type: Date

	def self.agregar(ut, ing, cant, rut, f)
		Ventacliente.create(utilidades: ut, ingresos: ing, cantidad_pedidos: cant, rut_cliente: rut, fecha: f)
	end

	def self.query
		Ventacliente.all.each do |venta|
  			puts venta.inspect
		end

	
	end
end