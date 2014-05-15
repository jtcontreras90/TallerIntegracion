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
		 response
		r=JSON.parse response
		puts response
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
		puts response
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
		signature
		key= 'wjNBuMv2'
		hash = (Base64.encode64("#{OpenSSL::HMAC.digest('sha1',key, signature)}"))
		hash
		response= RestClient.get "http://bodega-integracion-2014.herokuapp.com/stock?almacenId=#{almacenId}&sku=#{sku}", {:Authorization => "UC grupo9:#{hash}"}
		response
		r=JSON.parse response
		puts response
		r
	end
	#mueve un producto dado a una bodega dada de destino retornando el almacen y el producto o error(producto no encontrado, almacen no encontrado, falta de espacio)
	def self.moverStock(almacenId, productoId)      
		signature = "POST#{productoId}#{almacenId}"
		puts signature
		key= 'wjNBuMv2'
		hash = (Base64.encode64("#{OpenSSL::HMAC.digest('sha1',key, signature)}"))
		puts hash
		response= RestClient.post "http://bodega-integracion-2014.herokuapp.com/moveStock",{'productoId' => productoId, 'almacenId' => almacenId}, {:Authorization => "UC grupo9:#{hash}"}
		puts response
		r=JSON.parse response

		r
		
	end
		#mueve un producto de la bodega de despacho a la bodega que se desee incluyendo la de otros grupos. 
		#retorna el almacen y el producto. Errores: los mismos que mover stock pero incluye: producto no se encuentra en la guia de despacho. 
	def self.moverStockBodega(almacenId, productoId)      
		signature = "POST#{productoId}#{almacenId}"
		puts signature
		key= 'wjNBuMv2'
		hash = (Base64.encode64("#{OpenSSL::HMAC.digest('sha1',key, signature)}"))
		puts hash
		response= RestClient.post "http://bodega-integracion-2014.herokuapp.com/moveStockBodega",{'productoId' => productoId, 'almacenId' => almacenId}, {:Authorization => "UC grupo9:#{hash}"}
		puts response
		r=JSON.parse response

		r
		
	end

	def self.despacharStock(productoId, direccion, precio, pedidoId)
		signature = "DELETE#{productoId}#{direccion}#{precio}#{pedidoId}"
		puts signature
		key= 'wjNBuMv2'
		hash = (Base64.encode64("#{OpenSSL::HMAC.digest('sha1',key, signature)}"))
		puts hash
		#{'productoId' => productoId, 'direccion' => direccion,'precio' => precio, 'pedidoId' => pedidoId},
		parametros={productoId: productoId,direccion: direccion,precio: precio,pedidoId: pedidoId}
		#response= RestClient.delete "http://bodega-integracion-2014.herokuapp.com/stock?#{parametros.to_query}", {:Authorization => "UC grupo9:#{hash}"}
		response=RestClient::Request.execute(:method => 'delete', :url => "http://bodega-integracion-2014.herokuapp.com/stock",:headers =>{:Authorization => "UC grupo9:#{hash}"}, :payload =>parametros)
		#response= RestClient.delete 'http://bodega-integracion-2014.herokuapp.com/stock',{'Authorization' => hash,:accept => :json, :params=>{:productId=>productId, :dirección=>dirección, :precio=>precio,:pedidoId=>pedidoId}}
		puts response
		r=JSON.parse response

		r
		
	end

	def self.run
		#Bodega de recepción
		# ApiBodega.getSkusWithStock('53571e54682f95b80b786eb9')
		# #Para probar los despachos
		# ApiBodega.getStock('53571e54682f95b80b786eba', '2586731')
		# ApiBodega.getSkusWithStock("53571e54682f95b80b786eba")
		# ApiBodega.despacharStock('53571e55682f95b80b7899aa', 'Quinchamali 1433, Las Condes', '10000', '543535345345')
		# ApiBodega.getSkusWithStock('53571e54682f95b80b786eba')



		# #mover stock a la bodega de recepción del grupo de jose
		# ApiBodega.moverStockBodega('53571d58682f95b80b76e5ea', '53571e55682f95b80b7899aa')
		# ApiBodega.getSkusWithStock('53571e54682f95b80b786eba')

		ApiBodega.getStock("53571e54682f95b80b786ebb", '2586731')
		ApiBodega.moverBodegaDespacho('53571e55682f95b80b789979')

		# ApiBodega.getStock('53571e54682f95b80b786eba','2586731')
		# ApiBodega.getSkusWithStock('53571e54682f95b80b786eba')
		# ApiBodega.despacharStock('53571e55682f95b80b789997', 'Quinchamali 1433, Las Condes', '10000', '543535345345')
	
	end

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
		puts total

		total

	end

	def self.validarStock(sku,cantidad)
		stock=ApiBodega.obtenerStock(sku)
		if stock>=cantidad
			return true
		end
		false
	end

	def self.moverBodegaDespacho(productoId)
		
		ApiBodega.moverStock('53571e54682f95b80b786eba', productoId)
	end


end