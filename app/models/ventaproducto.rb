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


	##hacer consulta para obtener productos en un determinado rango
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
			query = Ventaproducto.where(:ingresos.gt => mayor_a, :ingresos.lte => menor_a)
		end

		if(igual1==false && igual2==false)
			puts '4'
			query = Ventaproducto.where(:ingresos.gt => mayor_a, :ingresos.lt => menor_a)
		end

		return query
	end

	
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
			Ventaproducto.id_attr(docs[i], :fecha)
			i+=1
			a = docs[i]
		end
		##puts suma
		puts q[:count]
		return q

	end

	def self.id_attr(id, var)
		puts Ventaproducto.where(:_id => id).distinct(var)
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