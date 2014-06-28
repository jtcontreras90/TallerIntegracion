require 'mongoid'

class Ventacliente
	include Mongoid::Document
	store_in collection: "ventasXcliente", database: "datawarehouse", session: "default"
	field :utilidades, type: Integer
	field :ingresos, type: Integer
	field :cantidad_pedidos, type: Integer
	field :rut_cliente, type: String
	field :fecha, type: DateTime

	def self.agregar(ut, ing, cant, rut, f)
		Ventacliente.create(utilidades: ut, ingresos: ing, cantidad_pedidos: cant, rut_cliente: rut, fecha: f)
	end

	def self.query
		Ventacliente.all.each do |venta|
  			puts venta.inspect
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
	
		when 'cantidad_pedidos' || 'cantidad'
			var = :cantidad_pedidos

		when 'rut' || 'rut_cliente'
			var = :rut_cliente

		when 'fecha'
			var = :fecha

		else 
			puts "No existe atributo #{var} --"
			return

		end

		if(igual1 && igual2)
			puts '1'
			query = Ventacliente.where(var.gte => mayor_a, var.lte => menor_a)
		  	##suma = collection.aggregate([{"$group" => { :sku_producto : "$sku_producto", :cantidad_transada => {"$sum" => "$cantidad_transada"}}}])
		end

		if(igual1 && !igual2)
			puts '2'
			query = Ventacliente.where(var.gte => mayor_a, var.lt => menor_a)
			##q = Ventacliente.where(var.gte => mayor_a, var.lt => menor_a).
		  ##distinct(:sku_producto)
 		end

		if(igual2 && !igual1)
			puts '3'
			query = Ventacliente.where(var.gt => mayor_a, var.lte => menor_a)
		end

		if(igual1==false && igual2==false)
			puts '4'
			query = Ventacliente.where(var.gt => mayor_a, var.lt => menor_a)
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
	
		when 'cantidad_pedidos' || 'cantidad'
			var = :cantidad_pedidos

		when 'rut' || 'rut_cliente'
			var = :rut_cliente

		when 'fecha'
			var = :fecha

		else
			var = :utilidades

		end

		q = {ids:query.distinct(:_id), 
			count: query.count, 
			sum: query.sum(var), 
			avg: query.avg(var),
			max: query.max(var),
			min: query.min(var)}
		puts var	
		puts q[:avg]			

		i=0
		docs = q[:ids]
		a=docs[0]
		while a!=nil do
			puts a
			puts "#{Ventacliente.id_attr(docs[i], :fecha)} -- #{Ventacliente.id_attr(docs[i], :rut_cliente)} -- #{Ventacliente.id_attr(docs[i], :cantidad_pedidos)}"
			i+=1
			a = docs[i]
		end
		##puts suma
		puts "count: #{q[:count]} -- avg: #{q[:avg]} -- max: #{q[:max]} -- min: #{q[:min]} "
		return q

	end

	##Retorna el valor de un atributo dado de la tupla de id dado
	##Parámetros
	##id : id de la tupla (se obtiene del hash obtenido de la query anterior o de la query que retorna query_attr_rango haciendo .inspect) 
	def self.id_attr(id, var)
		return Ventacliente.where(:_id => id).distinct(var)
	end

	def self.run
		##Ventacliente.agregar(40300,100000,3,13,DateTime.now)

		Ventacliente.query
		query = Ventacliente.query_attr_rango('fecha',DateTime.now, false, "2015-04-20", true)
		q = Ventacliente.aggr_attr(query, 'utilidades')
		puts Ventacliente.id_attr(q[:ids][0], 'fecha')
	end

	def self.run1
		Ventacliente.agregar(100000,101000,13,"77777777-7",DateTime.now)
		Ventacliente.agregar(23000,32000,5,"55555555-5","2014-05-19")
		Ventacliente.agregar(400,1000,7,"6666666-6","2014-04-20")
	end

end