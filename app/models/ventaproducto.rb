require 'mongoid'
##require "moped"
require 'pp'

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
		  	##suma = collection.aggregate([{"$group" => { :sku_producto : "$sku_producto", :cantidad_transada => {"$sum" => "$cantidad_transada"}}}])
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
		query = Ventaproducto.query_attr_rango('cantidad_transada',1, true, 6, false)
		q = Ventaproducto.aggr_attr(query, 'fecha')
		Ventaproducto.id_attr(q[:ids][3], :fecha)
	end

	def self.run1
		Ventaproducto.agregar(2000,4000,1,15,"2014-05-20")
	end
	
end