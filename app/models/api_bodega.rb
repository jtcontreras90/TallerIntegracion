class ApiBodega < ActiveRecord::Base

	require 'rest_client'
	require 'json'
	require 'base64'
	require 'cgi'
	require 'openssl'

	@@RECEPCION='53571e54682f95b80b786eb9'
	@@DESPACHO='53571e54682f95b80b786eba'
	@@PULMON='53571e58682f95b80b78d133'

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
	# }
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

	#Envía un stock a un cliente desde la bodega de despacho
	#Retorna un bool indicando si el producto fue entragado correctamente o no. 
	#Error producto no encontrado.
	def self.despacharStock(productoId, direccion, precio, pedidoId)
		signature = "DELETE#{productoId}#{direccion}#{precio}#{pedidoId}"
		#puts signature
		key= 'wjNBuMv2'
		hash = (Base64.encode64("#{OpenSSL::HMAC.digest('sha1',key, signature)}"))
		#puts hash
		#{'productoId' => productoId, 'direccion' => direccion,'precio' => precio, 'pedidoId' => pedidoId},
		parametros={productoId: productoId,direccion: direccion,precio: precio,pedidoId: pedidoId}
		#response= RestClient.delete "http://bodega-integracion-2014.herokuapp.com/stock?#{parametros.to_query}", {:Authorization => "UC grupo9:#{hash}"}
		puts "DELETE: http://bodega-integracion-2014.herokuapp.com/stock headers: (:Authorization => 'UC grupo9:#{hash}) payload: #{parametros} "
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
		#Corresponde a los productos que pidieron otras bodegas pero que aún no se han enviado
		yaEnviado=Transferencia.where(sku: sku, sent: false).sum(:cantidad)
		total=total-yaEnviado

		#Corresponde a los productos que se vendieron por spree pero que aún no se han enviado
		yaEnviado=EOrder.where(sku: sku, enviado:false).sum(:cantidad)
		total=total-yaEnviado
		
		if total < 0
			total=0
		end
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
		
		ApiBodega.moverStock(@@DESPACHO, productoId)
	end
	# mueve un producto a la bodega de recepción
	def self.moverProductoBodegaRecepcion(productoId)
		
		ApiBodega.moverStock(@@RECEPCION, productoId)
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
				if i<cantidad and j["_id"]!=@@DESPACHO
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
   					if i<cantidad and j["_id"]!=@@RECEPCION
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
		productos=ApiBodega.getStock(@@DESPACHO, sku)
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
			productos=ApiBodega.getStock(@@DESPACHO, sku)
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
    	Rails.logger.info "[SCHEDULE][APIBODEGA.VACIARBODEGARECEPCION]Begin at #{Time.now}"
		begin
			skus=ApiBodega.getSkusWithStock(@@RECEPCION)
			skus.each do |i|
				Rails.logger.info "[SCHEDULE][APIBODEGA.VACIARBODEGARECEPCION]Trying to move product with sku #{i}"
				j=0
				while j<i["total"]
					productos=ApiBodega.getStock(@@RECEPCION, i["_id"])
					productos.each do |k|
						if j<i["total"]
							
							ApiBodega.moverProductoBodegaCentra1(k["_id"])
							j=j+1
						end
					end
				end
			end	
		rescue Exception => e
			Rails.logger.info "[SCHEDULE][APIBODEGA.VACIARBODEGARECEPCION]There was an error: #{e}"
			begin
				skus=ApiBodega.getSkusWithStock(@@RECEPCION)
				skus.each do |i|
				j=0
				while j<i["total"]
					productos=ApiBodega.getStock(@@RECEPCION, i["_id"])
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
    	Rails.logger.info "[SCHEDULE][APIBODEGA.VACIARBODEGARECEPCION]Finish at #{Time.now}"
	end

		#intenta vaciar la bodega pulmon moviendo los productos a las dos bodegas centrales
	def self.vaciarBodegaPulmon
    	Rails.logger.info "[SCHEDULE][APIBODEGA.VACIARBODEGAPULMON]Begin at #{Time.now}"
		begin
			skus=ApiBodega.getSkusWithStock(@@PULMON)
			skus.each do |i|
				Rails.logger.info "[SCHEDULE][APIBODEGA.VACIARBODEGAPULMON]Trying to move product with sku #{i}"
				j=0
				while j<i["total"]
					productos=ApiBodega.getStock(@@PULMON, i["_id"])
					productos.each do |k|
						if j<i["total"]
							
							ApiBodega.moverProductoBodegaCentra1(k["_id"])
							j=j+1
						end
					end
				end
			end	
		rescue Exception => e
			Rails.logger.info "[SCHEDULE][APIBODEGA.VACIARBODEGAPULMON]There was an error: #{e}"
			begin
				skus=ApiBodega.getSkusWithStock(@@PULMON)
				skus.each do |i|
				j=0
				while j<i["total"]
					productos=ApiBodega.getStock(@@PULMON, i["_id"])
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
    	Rails.logger.info "[SCHEDULE][APIBODEGA.VACIARBODEGAPULMON]Finish at #{Time.now}"
		
	end

	# suma los costos de todos los productos de la bodega pulmon 
	def self.reportarBPulmonDw
		#costo diario de la bodega
    	Rails.logger.info "[SCHEDULE][APIBODEGA.REPORTARBPULMONDW]Begin at #{Time.now}"
		costoDia=0

		#Obtenemos los skus de la bodega pulmon que tienen stock
		skus=ApiBodega.getSkusWithStock(@@PULMON)
		puts "Pasa por aqui"
		skus.each do |i|
			#Iniciamos un contador
			# j=0
			# while j<i["total"] #i[total] corresponde a la cantidad total de stock en el almacen para el sku dado
			un_sku=i["_id"]
			productos=ApiBodega.getStock(@@PULMON, un_sku) #Obtener todos los id de los productos con sku dado en bodega dada
			productos.each do |k|
				puts "Productos con sku #{un_sku}, id #{k['_id']}"				
				costoDia=k["costo"].to_i+costoDia
			end
		end	
		#fecha que se reporta al datawerehouse
		time = Time.now
		fecha=time.inspect
		puts fecha
		#cantidad total de productos en la bodegaPulmon
		almacenes=getAlmacenes
		cantTotal= almacenes[3]["usedSpace"] 

		Costobodegapulmon.agregar(costoDia, fecha,cantTotal)

    	Rails.logger.info "[SCHEDULE][APIBODEGA.REPORTARBPULMONDW]Begin at #{Time.now}"
	end



	def self.run
		#Bodega de recepción
		# ApiBodega.getSkusWithStock(@@RECEPCION)
		# #Para probar los despachos
		# ApiBodega.getStock(@@DESPACHO, '2586731')
		# ApiBodega.getSkusWithStock(@@DESPACHO)
		# ApiBodega.despacharStock('53571e55682f95b80b7899aa', 'Quinchamali 1433, Las Condes', '10000', '543535345345')
		# ApiBodega.getSkusWithStock(@@DESPACHO)
		
		

		#reportarBPulmonDw
		ApiBodega.getAlmacenes()
		#ApiBodega.moverProductosBodegaRecepcion('3517982', 5)
		#ApiBodega.getAlmacenes()
		#ApiBodega.vaciarBodegaRecepcion()
		#ApiBodega.getAlmacenes()
		#ApiBodega.getSkusWithStock(@@DESPACHO)
		#ApiBodega.despacharProducto( '3517982', 1, 'queincha', '235234', '5555555555555')
		#ApiBodega.getSkusWithStock(@@DESPACHO)
		#ApiBodega.getStock(@@DESPACHO, '3517982' )

		# #mover stock a la bodega de recepción del grupo de jose
		# ApiBodega.moverStockBodega('53571d58682f95b80b76e5ea', '53571e55682f95b80b7899aa')
		# ApiBodega.getSkusWithStock(@@DESPACHO)

		#ApiBodega.getStock("53571e54682f95b80b786ebb", '2586731')
		#ApiBodega.moverBodegaDespacho('53571e55682f95b80b789979')

		# ApiBodega.getStock(@@DESPACHO,'2586731')
		# ApiBodega.getSkusWithStock(@@DESPACHO)
		# ApiBodega.despacharStock('53571e55682f95b80b789997', 'Quinchamali 1433, Las Condes', '10000', '543535345345')
	

	end

end