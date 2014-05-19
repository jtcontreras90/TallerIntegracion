class ApiBodega < ActiveRecord::Base

	require 'rest_client'
	require 'json'
	require 'base64'
	require 'cgi'
	require 'openssl'

	# retorna todos los almacenes de la bodega como Json: 
	# {"grupo"=>9, "_id"=>"53571e54682f95b80b786eb9", "pulmon"=>false, "despacho"=>false, "recepcion"=>true, "totalSpace"=>505, "usedSpace"=>1, "__v"=>0}
	# {"grupo"=>9, "_id"=>"53571e54682f95b80b786eba", "pulmon"=>false, "despacho"=>true, "recepcion"=>false, "totalSpace"=>211, "usedSpace"=>10, "__v"=>0}
	# {"grupo"=>9, "_id"=>"53571e54682f95b80b786ebb", "pulmon"=>false, "despacho"=>false, "recepcion"=>false, "totalSpace"=>27138, "usedSpace"=>25205, "__v"=>0}
	# {"grupo"=>9, "_id"=>"53571e58682f95b80b78d133", "pulmon"=>true, "despacho"=>false, "recepcion"=>false, "totalSpace"=>99999999, "usedSpace"=>0, "__v"=>0}
	# {"grupo"=>9, "_id"=>"53571e58682f95b80b78d132", "pulmon"=>false, "despacho"=>false, "recepcion"=>false, "totalSpace"=>3952, "usedSpace"=>0, "__v"=>0}
	def self.getAlmacenes
		response= RestClient.get "http://bodega-integracion-2014.herokuapp.com/almacenes", {:Authorization => "UC grupo9:vdgf4m3rusH1dXghLy9yMPGL+fk="}
		r=JSON.parse response
		#puts response
		r
	end

	#retorna todos los  productos de un almacen dado mostrando su sku y su cantidad. (Json)
	 # {
  		#   "_id": "2586731",
  		#   "total": 88
  	# }
	def self.getSkusWithStock(almacenId)
		key = 'wjNBuMv2'
		signature = "GET#{almacenId}"
		hash = (Base64.encode64("#{OpenSSL::HMAC.digest('sha1',key, signature)}"))
		response= RestClient.get "http://bodega-integracion-2014.herokuapp.com/skusWithStock?almacenId=#{almacenId}", {:Authorization => "UC grupo9:#{hash}"}
		r=JSON.parse response
		
		r
	end
	# dado un almacen y un sku, retorna todos los productos del almacen que tengan ese sku de la siguiente manera: 
	# {
 #    "grupo": 9,
 #    "almacen": "53571e54682f95b80b786ebb",
 #    "sku": "2586731",
 #    "_id": "53571e55682f95b80b7899b0",
 #    "direccion": "",
 #    "precio": 0,
 #    "despachado": false,
 #    "costo": 0,
 #    "__v": 0
 #  	}
	def self.getStock(almacenId, sku)
		signature = "GET#{almacenId}#{sku}"
		key= 'wjNBuMv2'
		hash = (Base64.encode64("#{OpenSSL::HMAC.digest('sha1',key, signature)}"))
		response= RestClient.get "http://bodega-integracion-2014.herokuapp.com/stock?almacenId=#{almacenId}&sku=#{sku}", {:Authorization => "UC grupo9:#{hash}"}
		r=JSON.parse response
		r
	end
	#mueve un producto dado a una bodega dada de destino retornando el almacen y el producto o error(producto no encontrado, almacen no encontrado, falta de espacio)
	def self.moverStock(almacenId, productoId)      
		signature = "POST#{productoId}#{almacenId}"
		key= 'wjNBuMv2'
		hash = (Base64.encode64("#{OpenSSL::HMAC.digest('sha1',key, signature)}"))
		response= RestClient.post "http://bodega-integracion-2014.herokuapp.com/moveStock",{'productoId' => productoId, 'almacenId' => almacenId}, {:Authorization => "UC grupo9:#{hash}"}
		#puts response
		r=JSON.parse response

		r
		
	end
		#mueve un producto de la bodega de despacho a la bodega que se desee incluyendo la de otros grupos. 
		#retorna el almacen y el producto. Errores: los mismos que mover stock pero incluye: producto no se encuentra en la guia de despacho. 
	def self.moverStockBodega(almacenId, productoId)      
		signature = "POST#{productoId}#{almacenId}"
		#puts signature
		key= 'wjNBuMv2'
		hash = (Base64.encode64("#{OpenSSL::HMAC.digest('sha1',key, signature)}"))
		##puts hash
		response= RestClient.post "http://bodega-integracion-2014.herokuapp.com/moveStockBodega",{'productoId' => productoId, 'almacenId' => almacenId}, {:Authorization => "UC grupo9:#{hash}"}
		##puts response
		r=JSON.parse response

		r
		
	end
		#Envía un stock a un cliente desde la bodega de despacho
		#Retorna un bool indicando si el producto fue entragado correctamente o no. 
		#Error producto no encontrado. ∫

	def self.despacharStock(productoId, direccion, precio, pedidoId)
		signature = "DELETE#{productoId}#{direccion}#{precio}#{pedidoId}"
		#puts signature
		key= 'wjNBuMv2'
		hash = (Base64.encode64("#{OpenSSL::HMAC.digest('sha1',key, signature)}"))
		#puts hash
		#{'productoId' => productoId, 'direccion' => direccion,'precio' => precio, 'pedidoId' => pedidoId},
		parametros={productoId: productoId,direccion: direccion,precio: precio,pedidoId: pedidoId}
		#response= RestClient.delete "http://bodega-integracion-2014.herokuapp.com/stock?#{parametros.to_query}", {:Authorization => "UC grupo9:#{hash}"}
		response=RestClient::Request.execute(:method => 'delete', :url => "http://bodega-integracion-2014.herokuapp.com/stock",:headers =>{:Authorization => "UC grupo9:#{hash}"}, :payload =>parametros)
		#response= RestClient.delete 'http://bodega-integracion-2014.herokuapp.com/stock',{'Authorization' => hash,:accept => :json, :params=>{:productId=>productId, :dirección=>dirección, :precio=>precio,:pedidoId=>pedidoId}}
		#puts response
		r=JSON.parse response

		r
		
	end


	# obtiene la cantidad de stock de un producto en todos los almacenes dado un sku
	def self.obtenerStock(sku)
		almacenes=ApiBodega.getAlmacenes
		total=0
		almacenes.each do |i|
			productos=ApiBodega.getSkusWithStock(i["_id"])
			productos.each do |j|
				if(j["_id"]==sku)
					total=j["total"]+total
				end	
			end	
				
		end
		#puts total

		total

	end
	# retorna un bool dependiendo si existe la cantidad de producto solicitada. 
	def self.validarStock(sku,cantidad)
		stock=ApiBodega.obtenerStock(sku)
		if stock>=cantidad
			return true
		end
		false
	end

	# mueve un producto a la bodega de despacho
	def self.moverProductoBodegaDespacho(productoId)
		
		ApiBodega.moverStock('53571e54682f95b80b786eba', productoId)
	end
	# mueve un producto a la bodega de recepción
	def self.moverProductoBodegaRecepcion(productoId)
		
		ApiBodega.moverStock('53571e54682f95b80b786eb9', productoId)
	end
	# mueve un producto a la bodega central1
	def self.moverProductoBodegaCentra1(productoId)
		
		ApiBodega.moverStock('53571e54682f95b80b786ebb', productoId)
	end
	# mueve un producto a la bodega central2
	def self.moverProductoBodegaCentra2(productoId)
		
		ApiBodega.moverStock('53571e58682f95b80b78d132', productoId)
	end
	# mueve todos los productos solicitados a la bodega de despacho, dado un sku y una cantidad
	def self.moverProductosBodegaDespacho(sku, cantidad)
		i = 0
		almacenes=ApiBodega.getAlmacenes
		#while i < cantidad do
		almacenes.each do |j|
			productos=ApiBodega.getStock(j["_id"],sku)
			productos.each	do |k|
				if i<cantidad and j["_id"]!='53571e54682f95b80b786eba'
					ApiBodega.moverProductoBodegaDespacho(k["_id"])
					i=i+1 
				end
			end
		end
		#end
		i
	end
	# mueve todos los productos solicitados a la bodega de Recepcion, dado un sku y una cantidad
	def self.moverProductosBodegaRecepcion(sku, cantidad)
		i = 0
		almacenes=ApiBodega.getAlmacenes
		# while i < cantidad do
   			almacenes.each do |j|
   				productos=ApiBodega.getStock(j["_id"],sku)
   				productos.each	do |k|
   					if i<cantidad and j["_id"]!='53571e54682f95b80b786eb9'
   						ApiBodega.moverProductoBodegaRecepcion(k["_id"])
   						i=i+1 
   					end
   				end
   			end
		# end
		i
	end


	#despacho otras bodegas dado el almacen de recepción de otro grupo, el sku y la cantidad. 
	def self.despacharOtrasBodegas(almacenId,sku,cantidad)
		#puts "Empezando todo"
		ApiBodega.moverProductosBodegaDespacho(sku, cantidad)
		#puts "Pasa por aquí"
		i = 0
		j = 0
		productos=ApiBodega.getStock('53571e54682f95b80b786eba', sku)
		#while i< cantidad do
			productos.each_with_index do |element,index|
				#puts "Cantidad enviada actual: #{i}"
				if i<cantidad and index >= j #
						#puts "Tratará de enviar el producto #{element["_id"]} a #{almacenId}"
   						ApiBodega.moverStockBodega(almacenId,element["_id"])
   						i=i+1 
   						j=j+1

   				end
			end	

		#end
		i	

	end
	# depachar productos a un cliente dado el sku y la cantidad, precio, dirección, pedido id
	def self.despacharProducto(sku, cantidad, direccion,precio,pedidoId)
		ApiBodega.moverProductosBodegaDespacho(sku, cantidad)
		i = 0
		#while i< cantidad do
			productos=ApiBodega.getStock('53571e54682f95b80b786eba', sku)
			productos.each do |j|
				if i<cantidad 
   						ApiBodega.despacharStock(j["_id"], direccion,precio,pedidoId)
   						i=i+1 
   				end
			end	

		#end	
	end

	#intenta vaciar la bodega de recepción moviendo los productos a las dos bodegas centrales
	def self.vaciarBodegaRecepcion
		begin
			skus=ApiBodega.getSkusWithStock('53571e54682f95b80b786eb9')
			skus.each do |i|
				j=0
				while j<i["total"]
					productos=ApiBodega.getStock('53571e54682f95b80b786eb9', i["_id"])
					productos.each do |k|
						if j<i["total"]
							
							ApiBodega.moverProductoBodegaCentra1(k["_id"])
							j=j+1
						end
					end
				end
			end	
		rescue Exception => e
			begin
				skus=ApiBodega.getSkusWithStock('53571e54682f95b80b786eb9')
				skus.each do |i|
				j=0
				while j<i["total"]
					productos=ApiBodega.getStock('53571e54682f95b80b786eb9', i["_id"])
					productos.each do |k|
						if j<i["total"]
							
							ApiBodega.moverProductoBodegaCentra2(k["_id"])
							j=j+1
						end
					end
				end
			end	

				
			rescue Exception => e
				
			end

			
		end
		
	end

		#intenta vaciar la bodega pulmon moviendo los productos a las dos bodegas centrales
	def self.vaciarBodegaPulmon
		begin
			skus=ApiBodega.getSkusWithStock('53571e58682f95b80b78d132')
			skus.each do |i|
				j=0
				while j<i["total"]
					productos=ApiBodega.getStock('53571e58682f95b80b78d132', i["_id"])
					productos.each do |k|
						if j<i["total"]
							
							ApiBodega.moverProductoBodegaCentra1(k["_id"])
							j=j+1
						end
					end
				end
			end	
		rescue Exception => e
			begin
				skus=ApiBodega.getSkusWithStock('53571e58682f95b80b78d132')
				skus.each do |i|
				j=0
				while j<i["total"]
					productos=ApiBodega.getStock('53571e58682f95b80b78d132', i["_id"])
					productos.each do |k|
						if j<i["total"]
							
							ApiBodega.moverProductoBodegaCentra2(k["_id"])
							j=j+1
						end
					end
				end
			end	

				
			rescue Exception => e
				
			end

			
		end
		
	end

	def self.run
		#Bodega de recepción
		# ApiBodega.getSkusWithStock('53571e54682f95b80b786eb9')
		# #Para probar los despachos
		# ApiBodega.getStock('53571e54682f95b80b786eba', '2586731')
		# ApiBodega.getSkusWithStock("53571e54682f95b80b786eba")
		# ApiBodega.despacharStock('53571e55682f95b80b7899aa', 'Quinchamali 1433, Las Condes', '10000', '543535345345')
		# ApiBodega.getSkusWithStock('53571e54682f95b80b786eba')

		#ApiBodega.getAlmacenes()
		#ApiBodega.moverProductosBodegaRecepcion('3517982', 5)
		#ApiBodega.getAlmacenes()
		#ApiBodega.vaciarBodegaRecepcion()
		#ApiBodega.getAlmacenes()
		#ApiBodega.getSkusWithStock('53571e54682f95b80b786eba')
		#ApiBodega.despacharProducto( '3517982', 1, 'queincha', '235234', '5555555555555')
		#ApiBodega.getSkusWithStock('53571e54682f95b80b786eba')
		#ApiBodega.getStock('53571e54682f95b80b786eba', '3517982' )

		# #mover stock a la bodega de recepción del grupo de jose
		# ApiBodega.moverStockBodega('53571d58682f95b80b76e5ea', '53571e55682f95b80b7899aa')
		# ApiBodega.getSkusWithStock('53571e54682f95b80b786eba')

		#ApiBodega.getStock("53571e54682f95b80b786ebb", '2586731')
		#ApiBodega.moverBodegaDespacho('53571e55682f95b80b789979')

		# ApiBodega.getStock('53571e54682f95b80b786eba','2586731')
		# ApiBodega.getSkusWithStock('53571e54682f95b80b786eba')
		# ApiBodega.despacharStock('53571e55682f95b80b789997', 'Quinchamali 1433, Las Condes', '10000', '543535345345')
	
	end

end