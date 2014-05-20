require 'mongoid'
require "moped"
require 'pp'
require 'date'

class Ventaproducto
	include Mongoid::Document
	store_in collection: "ventasXproducto", database: "datawarehouse", session: "default"
	field :utilidades, type: Integer
	field :ingresos, type: Integer
	field :cantidad_transada, type: Integer
	field :sku_producto, type: Integer
	field :fecha, type: DateTime

	def self.agregar(ut, ing, cant, sku, f)
		Ventaproducto.create(utilidades: ut, ingresos: ing, cantidad_transada: cant, sku_producto: sku, fecha: f)
	end

########################################################################################
####Para consultar por agregación respecto a cada producto usar método: aggr_attr_sku###
########################################################################################

	def self.query
		Ventaproducto.all.each do |venta|
			puts venta.inspect
			##v = venta.inspect
  			##puts v
			##return v
		end

	end

	##Hacer query para obtener productos en un determinado rango. Usar query luego para obtener algo que sirva
	##Parámetros:
	##var: atributo a filtrar (STRING)
	##mayor_a y menor_a: mayor y menor valor del rango respectivamente
	##igual1 e igual2: true si es mayor/menor igual flase si es desigualdad estricta
	def self.query_attr_rango(var, mayor_a, igual1,menor_a, igual2)

		case var 
		
		when 'utilidades'
			var = :utilidades

		when 'ingresos'
			var = :ingresos
	
		when 'cantidad_transada'
			var = :cantidad_transada

		when 'sku_producto'
			var = :sku_producto

		when 'fecha'
			var = :fecha

		else 
			puts "No existe atributo #{var} --"
			return

		end

		if(igual1 && igual2)
			puts '1'
			query = Ventaproducto.where(var.gte => mayor_a, var.lte => menor_a)
		  	puts  Ventaproducto.collection.aggregate([{"$match" => {var => {"$gte" => mayor_a}}},{ "$group" => { "_id" => "$sku_producto", "total_ingresos" => {"$sum"=>"$ingresos"} } }])
		end

		if(igual1 && !igual2)
			puts '2'
			query = Ventaproducto.where(var.gte => mayor_a, var.lt => menor_a)
			##q = Ventaproducto.where(var.gte => mayor_a, var.lt => menor_a).
		  ##distinct(:sku_producto)
 		end

		if(igual2 && !igual1)
			puts '3'
			query = Ventaproducto.where(var.gt => mayor_a, var.lte => menor_a)
		end

		if(igual1==false && igual2==false)
			puts '4'
			query = Ventaproducto.where(var.gt => mayor_a, var.lt => menor_a)
		end

		return query
	end

	##Recibe una query onbtenida con el método anterior y a partir de ella obtener avg, min ,max de un atributo dado
	##Si se quiere solo los id's o la cantidad(count) darle cualquier atributo o cualquier cosa
	##Parámetros:
	##query: usar valor retornado por método anterior
	##var: atributo al que se le quiere hacer agregación
	##Retorna un hash en que:
	##[:ids] : id's de las tuplas en el rango
	##[:count] : cantidad de tuplas en el rango
	##[:avg] : promedio del atributo entregado(var) en las tuplas dentro del rango
	##[:min] : mínimo del atributo entregado(var) en las tuplas dentro del rango
	##[:max] : máximo del atributo entregado(var) en las tuplas dentro del rango
	def self.aggr_attr(query, var)

		case var 
		
		when 'utilidades'
			var = :utilidades

		when 'ingresos'
			var = :ingresos
	
		when 'cantidad_transada'
			var = :cantidad_transada

		when 'sku_producto'
			var = :sku_producto

		when 'fecha'
			var = :fecha

		else
			var = :utilidades

		end

		q = {ids:query.distinct(:_id) , 
			count: query.count, 
			sum: query.sum(var), 
			avg: query.avg(var),
			max: query.max(var),
			min: query.min(var)}
		puts var	
		puts q[:max]			

		i=0
		docs = q[:ids]
		a=docs[0]
		while a!=nil do
			puts a
			puts "#{Ventaproducto.id_attr(docs[i], :fecha)} -- #{Ventaproducto.id_attr(docs[i], :sku_producto)} -- #{Ventaproducto.id_attr(docs[i], :cantidad_transada)}"
			i+=1
			a = docs[i]
		end
		##puts suma
		puts q[:count]
		return q

	end

	##Retorna el valor de un atributo dado de la tupla de id dado
	##Parámetros
	##id : id de la tupla (se obtiene del hash obtenido de la query anterior o de la query que retorna query_attr_rango haciendo .inspect) 
	def self.id_attr(id, var)
		return Ventaproducto.where(:_id => id).distinct(var)
	end


	def self.run
		##Ventaproducto.agregar(40300,100000,3,13,DateTime.now)
		Ventaproducto.query
		date1 = "2014-04-17T23:59:59+05:30".gsub(/T.*/, '')
		date2 = "2014-04-19T23:59:59+05:30".gsub(/T.*/, '')
		#query = Ventaproducto.query_attr_rango('fecha',DateTime.parse(date), true,DateTime.now, true)
		#q = Ventaproducto.aggr_attr(query, 'fecha')
		q=Ventaproducto.agg_attr_sku('max', 'utilidades', DateTime.parse(date1),DateTime.parse(date2))
		#Ventaproducto.id_attr(q[:ids][3], :fecha)
		Ventaproducto.agg_attr_sku('max', 'ingresos', DateTime.parse(date1),DateTime.parse(date2))
		Ventaproducto.agg_attr_sku('max', 'cantidad_transada', DateTime.parse(date1),DateTime.parse(date2))
		
		q.each do |y|
			puts y['max_utilidades']
		end

	end

	def self.run1
		Ventaproducto.collection.find.remove_all

		date = "2014-04-18T23:59:59+05:30".gsub(/T.*/, '')
		Ventaproducto.agregar(600,1000,2,1,DateTime.parse(date))
		Ventaproducto.agregar(212000,232000,8,12,DateTime.parse(date))
		Ventaproducto.agregar(121000,401000,5,123,DateTime.parse(date))
		Ventaproducto.agregar(2000,8000,3,1234,DateTime.parse(date))
		Ventaproducto.agregar(2500000,6000000,4,12,DateTime.parse(date))

		date = "2014-04-28T23:59:59+05:30".gsub(/T.*/, '')
		Ventaproducto.agregar(6000,12000,3,1,DateTime.parse(date))
		Ventaproducto.agregar(22000,23000,4,12,DateTime.parse(date))
		Ventaproducto.agregar(21000,40000,10,1234,DateTime.parse(date))
		Ventaproducto.agregar(2000,800000,1,123,DateTime.parse(date))
		Ventaproducto.agregar(22500,60000,7,1,DateTime.parse(date))


		date = "2014-05-19T23:59:59+05:30".gsub(/T.*/, '')
		Ventaproducto.agregar(50,100,3,123,DateTime.parse(date))
		Ventaproducto.agregar(221000,232000,8,12,DateTime.parse(date))
		Ventaproducto.agregar(31000,40000,11,1234,DateTime.parse(date))
		Ventaproducto.agregar(4000,4100,3,1234,DateTime.parse(date))
		Ventaproducto.agregar(2500,5000,1,1,DateTime.parse(date))


		Ventaproducto.agregar(60000,61000,2,1,DateTime.now)
		Ventaproducto.agregar(22000,23000,2,1234,DateTime.now)
		Ventaproducto.agregar(2100,4000,2,123,DateTime.now)
		Ventaproducto.agregar(23000,28000,2,123,DateTime.now)
		Ventaproducto.agregar(12500,16000,2,12,DateTime.now)
	end

	
end