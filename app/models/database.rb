#README
#para leer un archivo desde dropbox y guardarlo ejecutar el código siguiente
#Primero importar librerias pertinentes
require 'dropbox_sdk'
require 'pp'
require 'mdb'
require 'csv'

class Database
	@@APP_KEY = "gwxgw4dfw8p4n8q"
	@@APP_SECRET = "smokt05md0m4q5n"
	@@ACCESS_TYPE = :dropbox
	
	def self.prueba(dest)
		puts "Iniciando conversion de accdb a csv"
		database = Mdb.open(dest)
		# puts "#{database}"
		# puts "#{database.tables}"

		pricing= database.read("Pricing")
		pricing.each do |i|
		 	puts i
		end

		# csv = execute "mdb-export -D '%F %T' -d , DBPrecios.accdb  Pricing > hola.csv"
		
		# puts "Archivo csv creado"

	end
	#def self.findBySKU(table,sku)
	#	table.each do |i|
	#		if i[:SKU] == sku
	#			puts i
	#		end
	#	end
	#end

	def self.execute(command)
      stdout = `#{command} 2> /dev/null`
      
      # !todo: add fixture data and a test to prove this code
      if stdout.respond_to?(:force_encoding)
        stdout.force_encoding("Windows-1252")
        stdout.encode!("utf-8")
      end
      
      stdout
    end

    def self.accdb_to_csv
      	Rails.logger.info "[SCHEDULE][DATABASE.ACCDB_TO_CSV]Begin at #{Time.now}"

    	#Iniciar la sesión

		@session = DropboxSession.new(@@APP_KEY, @@APP_SECRET)
		@client = nil

		#Setear los tokens
		@session.set_access_token('mkvfcevi7josno9v','7pu9jl9t8c77yg0')

		#Generar una clase DropboxClient (ver archivo dopbox_sdk.rb)
		@client = DropboxClient.new(@session, @@ACCESS_TYPE)



		#Luego el código para leerlo
		src = "/Grupo9/DBPrecios.accdb" #poner path del archivo en dropbox
		dest = "DBPrecios.accdb" #poner nombre del archivo a guardar (o path)
		puts "src: " + src
		out = @client.get_file('/' + src)
		open(dest, 'w'){|f| f.puts out.force_encoding('UTF-8') }
		
		# {:Id=>"4039", :SKU=>"000000000880159182", :Precio=>" 19119.00000",
		#  :"Fecha Actualización"=>" 02/11/2015", :"Fecha Vigencia"=>" 04/09/2015", 
		#  :"Costo Producto"=>" 12906.00000", :"Costo Traspaso"=>" 229.00000", :"Costo Almacenaje Ext"=>" 30.00000"}
		database = Mdb.open(dest)
		pricing= database.read("Pricing")
		pricing.each do |i|
	        puts i
	        p=Pricing.where(id_pricing: i[:Id].to_i)
	        p.delete_all
	        pnew=Pricing.new
	        pnew.id_pricing = i[:Id].to_i
	        pnew.sku = i[:SKU]
	        pnew.precio = i[:Precio].to_i
	        pnew.fecha_actualizacion = Date.strptime(i[:"Fecha Actualización"].strip,"%m/%d/%Y")
	        pnew.fecha_vigencia = Date.strptime(i[:"Fecha Vigencia"].strip,"%m/%d/%Y")
	        pnew.costo_producto = i[:"Costo Producto"].to_i
	        pnew.costo_traspaso = i[:"Costo Traspaso"].to_i
	        pnew.costo_almacenaje = i[:"Costo Almacenaje Ext"].to_i
	        pnew.save
		end

      	Rails.logger.info "[SCHEDULE][DATABASE.ACCDB_TO_CSV]Finish at #{Time.now}"
    end

    def self.readcsv
    	Rails.logger.info "[SCHEDULE][DATABASE.READCSV]Begin at #{Time.now}"
    	@session = DropboxSession.new(@@APP_KEY, @@APP_SECRET)
		@client = nil

		#Setear los tokens
		@session.set_access_token('mkvfcevi7josno9v','7pu9jl9t8c77yg0')

		#Generar una clase DropboxClient (ver archivo dopbox_sdk.rb)
		@client = DropboxClient.new(@session, @@ACCESS_TYPE)



		#Luego el código para leerlo
		src = "/Grupo9/dbprecios.csv" #poner path del archivo en dropbox
		dest = "dbprecios.csv" #poner nombre del archivo a guardar (o path)
		puts "src: " + src
		out = @client.get_file('/' + src)
		open(dest, 'w'){|f| f.puts out.force_encoding('UTF-8') }
		
		puts "wrote file #{dest}."

		#customers = CSV.read('dbprecios.csv')
		#puts customers
		i=0
		Pricing.delete_all
		CSV.foreach('dbprecios.csv') do |row|
			if i > 0
		  	#puts row[1]
		  	p = Pricing.new
		  	p.id_pricing = row[0].to_i
		  	p.sku = row[1]
		  	p.precio = row[2].to_i
		  	p.fecha_actualizacion = Date.strptime(row[3].strip,"%m/%d/%Y")
		  	p.fecha_vigencia = Date.strptime(row[4].strip,"%m/%d/%Y")
		  	p.costo_producto = row[5].to_i
		  	p.costo_traspaso = row[6].to_i
		  	p.costo_almacenaje = row[7].to_i
		  	puts p
		  	p.save
		  	end
		  	i=i+1
		end
    	Rails.logger.info "[SCHEDULE][DATABASE.READCSV]Finish at #{Time.now}"
    end

end




