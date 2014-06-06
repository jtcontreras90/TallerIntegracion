require 'mongoid'

class Costobodegapulmon
	include Mongoid::Document
	store_in collection: "costosXbodegapulmon", database: "datawarehouse", session: "default"
	field :costo, type: Integer
	field :fecha, type: DateTime
	field :cantidad_productos, type: Integer

	def self.agregar(c, f, cant)
		Costobodegapulmon.create(costo: c, fecha: f, cantidad_productos: cant)
	end

	def self.query
		Costobodegapulmon.all.each do |costo|
  			puts costo.inspect
		end	
	end


##Hacer query para obtener productos en un determinado rango. Usar query luego para obtener algo que sirva
	##Parámetros:
	##var: atributo a filtrar (STRING)
	##mayor_a y menor_a: mayor y menor valor del rango respectivamente
	##igual1 e igual2: true si es mayor/menor igual flase si es desigualdad estricta
	def self.query_attr_rango(var, mayor_a, igual1,menor_a, igual2)

		case var 
		
		when 'costo'
			var = :costo

		when 'cantidad' || 'cantidad_productos'
			var = :fecha

		when 'fecha'
			var = :cantidad_productos

		else 
			puts "No existe atributo #{var} --"
			return

		end

		if(igual1 && igual2)
			puts '1'
			query = Costobodegapulmon.where(var.gte => mayor_a, var.lte => menor_a)
		  	##suma = collection.aggregate([{"$group" => { :sku_producto : "$sku_producto", :cantidad_transada => {"$sum" => "$cantidad_transada"}}}])
		end

		if(igual1 && !igual2)
			puts '2'
			query = Costobodegapulmon.where(var.gte => mayor_a, var.lt => menor_a)
			##q = Costobodegapulmon.where(var.gte => mayor_a, var.lt => menor_a).
		  ##distinct(:sku_producto)
 		end

		if(igual2 && !igual1)
			puts '3'
			query = Costobodegapulmon.where(var.gt => mayor_a, var.lte => menor_a)
		end

		if(igual1==false && igual2==false)
			puts '4'
			query = Costobodegapulmon.where(var.gt => mayor_a, var.lt => menor_a)
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
		
		when 'costo'
			var = :sku_producto

		when 'cantidad' || 'cantidad_productos'
			var = :rut_cliente

		when 'fecha'
			var = :fecha

		else 
			var = :fecha

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
			puts "#{Costobodegapulmon.id_attr(docs[i], :fecha)} -- #{Costobodegapulmon.id_attr(docs[i], :rut_cliente)} -- #{Costobodegapulmon.id_attr(docs[i], :sku_producto)}"
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

	##var: atributo a que se busca
	def self.id_attr(id, var)
		return Costobodegapulmon.where(:_id => id).distinct(var)
	end

	##Retorna el valor de un atributo dado un valor determinado del otro
	##Parámetros
	##var1 : atrinuto que se conoce
	##val : valor del atributo que se conoce
	##var2: atributo a que se busca
	def self.attr_attr(var1, val, var2)
		case var1 
		
		when 'costo'
			var1 = :sku_producto

		when 'cantidad' || 'cantidad_productos'
			var1 = :rut_cliente

		when 'fecha'
			var1 = :fecha

		else 
			var1 = :fecha

		end

		case var2
		
		when 'costo'
			var2 = :sku_producto

		when 'cantidad' || 'cantidad_productos'
			var2 = :rut_cliente

		when 'fecha'
			var2 = :fecha

		else 
			var2 = :fecha

		end

		return Costobodegapulmon.where(var1=> val).distinct(var2)
	end

	def self.run
		##Costobodegapulmon.agregar(40300,100000,3,13,DateTime.now)
		Costobodegapulmon.query
		query = Costobodegapulmon.query_attr_rango('fecha',DateTime.now, false, "2015-04-11", false)
		q = Costobodegapulmon.aggr_attr(query, 'costo')
		puts Costobodegapulmon.id_attr(q[:ids][0], 'fecha')
		puts Costobodegapulmon.attr_attr('fecha',123,'costo')
	end

	def self.run1
		####
	end


end