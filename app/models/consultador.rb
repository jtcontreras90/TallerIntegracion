require 'mongoid'
require "moped"
require 'date'

class Consultador

	##Para la colección entregada buscar 
	def self.total(obj, var, mayor_a, menor_a)
		query = obj.query_attr_rango('fecha',mayor_a, true, menor_a, true)
		q = obj.aggr_attr(query, var)
		puts q[:sum]
		return q

	end
	##Método para consultar algún tipo de agregación en la colección, para un determinado rango de fechas
	##Se agrega por sku_producto
	##Parámetros:
	##obj: Nombre de la clase de la case de la colección a consultar ('Ventacliente', 'Ventaproducto', 'Quiebre', 'Costobodegapulmon')
	##op: operación a ocupar ('sum', 'avg', 'max', 'min', 'top'), ***Para obj='Quiebre' sólo usar op='top'
	##var: el atributo que se quiere agregar ('utilidades','cantidad_transada','ingresos') 
	##      *En caso de op=top insertar por var un int que límite la cantidad de tuplas a mostrar
	##mayor_a: fecha límite inferior 
	##menor_a: fecha límite superior
	def self.agg_attr_sku(obj, op, var, mayor_a, menor_a)

		id = '$sku_producto'
		case obj
		when Ventacliente
			id = '$rut_cliente'
		when Ventaproducto
			id = '$sku_producto'
		when Quiebre
			quiebre = true
		when Costobodegapulmon
			##
			
		end



		operacion = "$#{op}"
		att = "$#{var}"
		nom = "#{op}_#{var}"
		puts 'ahora'
		cant = 10
		if op!='top'
			query = obj.collection.aggregate([{"$match" => {:fecha => {"$gte" => mayor_a, "$lte" => menor_a}}},{ "$group" => { "_id" => id, nom => {operacion=>att} } },{"$sort" => {nom => -1}}])			
		else
			query1 = obj.collection.aggregate([{"$match" => {:fecha => {"$gte" => mayor_a, "$lte" => menor_a}}},{ "$group" => { "_id" => id, "count"=>{"$sum"=>1} } }, {"$sort" => {"count"=> -1}},{"$limit" => var}])	
			if quiebre
				id = '$rut_cliente'
				query2 = obj.collection.aggregate([{"$match" => {:fecha => {"$gte" => mayor_a, "$lte" => menor_a}}},{ "$group" => { "_id" => id, "count"=>{"$sum"=>1} } }, {"$sort" => {"count"=> -1}},{"$limit" => var}])	
				query = {sku: query1,rut: query2}
			else
				query = query1
			end

		end

		

		puts query


		return query
	end

	def self.run
		##Ventaproducto.agregar(40300,100000,3,13,DateTime.now)
		Quiebre.query
		date1 = "2014-05-17T23:59:59+05:30".gsub(/T.*/, '')
		date2 = "2014-05-20T23:59:59+05:30".gsub(/T.*/, '')
		#query = Ventaproducto.query_attr_rango('fecha',DateTime.parse(date), true,DateTime.now, true)
		#q = Ventaproducto.aggr_attr(query, 'fecha')
		q=Consultador.agg_attr_sku(Ventaproducto, 'top', 4, DateTime.parse(date1),DateTime.parse(date2))
		#Ventaproducto.id_attr(q[:ids][3], :fecha)
		Consultador.agg_attr_sku(Ventaproducto, 'avg', 'ingresos', DateTime.parse(date1),DateTime.parse(date2))
		Consultador.agg_attr_sku(Ventaproducto, 'sum', 'cantidad_transada', DateTime.parse(date1),DateTime.parse(date2))
		Consultador.agg_attr_sku(Ventaproducto, 'sum', 'cantidad_transada', DateTime.parse(date1),DateTime.parse(date2))
		Consultador.agg_attr_sku(Quiebre, 'top', 5, DateTime.parse(date1),DateTime.parse(date2))
		q.each do |y|
		puts y['count']
		end
		Consultador.total(Ventaproducto,'ingresos',date1,date2)
	end

end
