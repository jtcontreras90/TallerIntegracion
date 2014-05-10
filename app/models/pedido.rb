require 'mongoid'
class Pedido
	include Mongoid::Document
	store_in collection: "informacion_historica", database: "datawarehouse"
	field :fecha_Pedido, type: String
	field :sku_Pedido, type: Integer
	field :cantidad_Pedido, type: Integer
	field :rut_Cliente, type: String
	field :quiebre_Stock, type: String


end


Pedido.create(fecha_Pedido: "12-01-2014", sku_Pedido: 123, cantidad_Pedido: 12, rut_Cliente: "1233123123", quiebre_Stock: "si" )