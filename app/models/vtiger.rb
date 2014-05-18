class Vtiger
	require 'rest_client'
	require 'digest/md5'
	require 'json'
	require 'uri'

	@@base="http://integra.ing.puc.cl/vtigerCRM"
	@@user="grupo9"
	@@key="zr83VHrqHHuH9DHC"

	@sessName=''

	def initialize
		puts "entra"
		begin
			login
		rescue
			nil
		end
	end

	#Se deslogea
	def logout
		apiconect("logout",:get,"&sessionName=#{@sessName}")
	end

	def findAccountByRut(rut)
		condition= "cf_705 = '#{rut}'"
		response= vFind('Accounts',condition)
		if "#{response['success']}"=="true" and response['result'].count > 0
			response["result"][0]
		else
			false
		end
	end

	def findContactsFromAccount(account_id)
		response=vFind("Contacts","account_id = '#{account_id}'")
		if "#{response['success']}"=="true" and response['result'].count > 0
			response["result"]
		else
			false
		end
		
	end

	private

	#Realiza las conexiones y devuelve la conexión correspondiente
	def processLogin
		token= (apiconect("getchallenge",:get,"&username=#{@@user}"))["result"]["token"]
		digest_string="#{token}#{@@key}"
		finalKey= Digest::MD5.hexdigest(digest_string) #Acess-key
		params= {'operation'=>'login', 'username'=>"#{@@user}", 'accessKey'=>finalKey}
		apiconect("login",:post,"",params)
	end

	#Realiza el login
	def login
		login= processLogin
		raise "Algo salió mal al tratar de conectarse con la API de vTigerCRM" unless "#{login["success"]}"=='true'
		@sessName="#{login['result']['sessionName']}"
		puts "Logeado con el userid #{login['result']['userId']} y sessionid #{login['result']['sessionName']}"
	end

	#Realiza un encoding del & que a veces genera problemas
	def encode(val) #Fix del problema con los ampersands en las querys
		query=URI.encode(val)
		query.gsub('&',"%26")
	end

	#Realiza una query en la entity (tabla) dada parecido a un sql
	def vFind(entity,condition="1=1")
		query=encode("select * from #{entity} where #{condition};")
		apiconect("query",:get,"&sessionName=#{@sessName}&query=#{query}")
	end

	#Realiza la conexión con el api
	def apiconect(operation,method,urlparams,params={})
		resource= "#{@@base}/webservice.php?operation=#{operation}#{urlparams}"
		# puts resource
		if method==:get
			response = RestClient.get resource
		elsif method==:post
			response = RestClient.post resource, params
		end
		# puts response
		JSON.parse response
	end


	# def self.example
	# 	Vtiger.login
	# 	response= Vtiger.apiconect("listtypes",:get,"&sessionName=#{@sessName}")
	# 	response= Vtiger.apiconect("describe",:get,"&sessionName=#{@sessName}&elementType=Accounts")
	# 	response = Vtiger.apiconect("query",:get,"&sessionName=#{@sessName}&query=#{URI.encode("select accountname,account_no, assigned_user_id, modifiedby, cf_705, id from Accounts;")}")
	# 	v=Vtiger.findAccountByRut('6210993-9')

	# 	if v
	# 		contacts=Vtiger.findContactsFromAccount(v['id'])
	# 		if contacts
	# 			contacts.each do |c|
	# 				puts "#{c['otherstreet']}, #{c['othercity']}, #{c['otherstate']}"
	# 			end
	# 		end
	# 	end
	# 	puts response

		
	# 	query=Vtiger.encode("select cf_705 from Accounts;")
	# 	a=Vtiger.apiconect("query",:get,"&sessionName=#{@sessName}&query=#{query}")
	# 	a['result'].each do |r|
	# 		contacts=Vtiger.findContactsFromAccount(r['id'])
	# 		if contacts
	# 			contacts.each do |c|
	# 				puts "#{c['otherstreet']}, #{c['othercity']}, #{c['otherstate']}"
	# 			end
	# 		end
	# 	end
	# end
		




end

