class ApiRabbit

require "bunny" # don't forget to put gem "bunny" in your Gemfile 
	


	def self.test
		
		# establece la conexión con el servidor
		#q = b.queue 'reposicion' # declare a queue
		
		#q.subscribe(:block => true, :ack => true) do |delivery_info, properties, payload|
  		#	puts "Received #
		b = Bunny.new "amqp://yxvcbgvv:4gDXD-JwLSCmVPtMwDiTEzEiWHi-O4AY@hyena.rmq.cloudamqp.com/yxvcbgvv"
		b.start # start a communication session with the amqp server
		puts b.status 

		#comprueba si la cola existe
		puts b.queue_exists?("reposicion")
		puts b.queue_exists?("ofertas")

		#{payload}, message properties are #{properties.inspect}"
		#end
		q = b.queue("ofertas",  :auto_delete => true)
		
		q.subscribe(:block => true) do | delivery_info, metadata, payload | 
			puts "Received #{payload} at #{metadata}"
		end


		#declare default direct exchange which is bound to all queues
		# e = b.exchange("")

		#publish a message to the exchange which then gets routed to the queue
		#e.publish("Hello, everybody!", :key => 'test1'


		delivery_info, properties, payload = q.pop # get message from the queue
		puts payload


		r=JSON.parse payload
		puts r["sku"]

		#b.stop # close the connection

	end
	# se conecta con la cola Rabbitmq y ejecuta lo que se encuantra dentro del do, por cada mensaje. La conexión que siempre escuchando y ejecuta al llegar un nuevo mensaje
	def self.subscribeOfertas()
		Rails.logger.info "[SCHEDULE][SUBSCRIBEOFERTAS]Begin at #{Time.now}"

		#conexión con Rabbitmq
		b= Bunny.new "amqp://yxvcbgvv:4gDXD-JwLSCmVPtMwDiTEzEiWHi-O4AY@hyena.rmq.cloudamqp.com/yxvcbgvv"
		b.start
		q = b.queue("ofertas",  :auto_delete => true)
		
		#q.subscribe(:block => true) do | delivery_info, metadata, payload | 
		q.subscribe do | delivery_info, metadata, payload | 
			puts "Received #{payload} at #{metadata}"
			r=JSON.parse payload
			Rails.logger.info "[RABBIT MQ][OFERTA]Received #{payload}"

			oferta=Oferta.new
			oferta.sku=r["sku"]
			oferta.precio=r["precio"]
			oferta.fecha_inicio=DateTime.strptime("#{r["inicio"].to_i/1000}",'%s')
			oferta.fecha_termino=DateTime.strptime("#{r["fin"].to_i/1000}",'%s')
			oferta.publicado=false
			oferta.save
			puts r["sku"]
			puts r["precio"]
			puts r["inicio"]
			puts r["fin"]

		end

		b.close
		Rails.logger.info "[SCHEDULE][SUBSCRIBEOFERTAS]Finish at #{Time.now}"
	end

	def self.subscribeReposicion()
		Rails.logger.info "[SCHEDULE][SUBSCRIBEREPOSICION]Begin at #{Time.now}"

		#conexión con Rabbitmq
		b= Bunny.new "amqp://yxvcbgvv:4gDXD-JwLSCmVPtMwDiTEzEiWHi-O4AY@hyena.rmq.cloudamqp.com/yxvcbgvv"
		b.start
		q = b.queue("reposicion",  :auto_delete => true)

		#q.subscribe(:block => true) do | delivery_info, metadata, payload | 
		i=0
		q.subscribe do | delivery_info, metadata, payload | 

		
		#q.subscribe(:block => true, :on_cancellation => reconnect) do | delivery_info, metadata, payload | 
			puts "Received #{payload} at #{metadata}"
			Rails.logger.info "[RABBIT MQ][REPOSICION]Received #{payload}"
			i=i+1
		end

		if i > 0
    		Rails.logger.info "[SCHEDULE][APIBODEGA.VACIARBODEGARECEPCION]Executed by SUBSCRIBEREPOSICION"
			ApiBodega.vaciarBodegaRecepcion
		end

		b.close
		Rails.logger.info "[SCHEDULE][SUBSCRIBEREPOSICION]Finish at #{Time.now}"

	end

	

	def self.largeOfertas()
		b = Bunny.new "amqp://yxvcbgvv:4gDXD-JwLSCmVPtMwDiTEzEiWHi-O4AY@hyena.rmq.cloudamqp.com/yxvcbgvv"
		b.start # start a communication session with the amqp server
		q = b.queue("ofertas",  :auto_delete => true)
		return puts q.message_count
	end

	def self.largeReposicion()
		b = Bunny.new "amqp://yxvcbgvv:4gDXD-JwLSCmVPtMwDiTEzEiWHi-O4AY@hyena.rmq.cloudamqp.com/yxvcbgvv"
		b.start # start a communication session with the amqp server
		q = b.queue("reposicion",  :auto_delete => true)
		return puts q.message_count
		
	end
end