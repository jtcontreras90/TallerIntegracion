#README
#para leer un archivo desde dropbox y guardarlo ejecutar el código siguiente
#Primero importar librerias pertinentes
require 'dropbox_sdk'
require 'pp'
require 'mdb'

class Database
	def self.prueba(dest)
		puts "Hola"
		database = Mdb.open(dest)
		# puts "#{database}"
		puts "#{database.tables}"

		pricing= database.read("Pricing")
		# pricing.each do |i|
		# 	puts i
		 #end

		 Database.findBySKU(pricing,"0000000003405574")
		# p= pricing.select{|key, hash| hash["SKU"] == "0000000003405574" }
		# # p=assert_equal 1716261, pricing[:SKU]
		# puts p
		# database.tables.each do |t|

		# 	begin
		# 	puts database.columns(t)
		# 	rescue
		# 		puts "Problemas con #{t}"
		# 	end
		# end
		# puts database.tables.to_s
		# puts database["Class"]
		puts "Chao"
	end
	def self.findBySKU(table,sku)
		table.each do |i|
			if i[:SKU] == sku
				puts i
			end
		end
	end
end

#Iniciar la sesión
APP_KEY = "gwxgw4dfw8p4n8q"
APP_SECRET = "smokt05md0m4q5n"
ACCESS_TYPE = :dropbox

@session = DropboxSession.new(APP_KEY, APP_SECRET)
@client = nil

#Setear los tokens
@session.set_access_token('mkvfcevi7josno9v','7pu9jl9t8c77yg0')

#Generar una clase DropboxClient (ver archivo dopbox_sdk.rb)
@client = DropboxClient.new(@session, ACCESS_TYPE)



#Luego el código para leerlo
src = "/Grupo9/DBPrecios.mdb" #poner path del archivo en dropbox
dest = "DBPrecios.mdb" #poner nombre del archivo a guardar (o path)
puts "src: " + src
out = @client.get_file('/' + src)
open(dest, 'w'){|f| f.puts out }
puts "wrote file #{dest}."

Database.prueba(dest)


