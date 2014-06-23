class Bodega < ActiveRecord::Base

  has_many :transferencias
  require 'rest_client'
  require 'json'

  def self.find_by_username(username)
    Bodega.where(name: username).first
  end

  def self.enviarProducto
    Rails.logger.info "[SCHEDULE][BODEGA.ENVIARPRODUCTO]Begin at #{Time.now}, processing #{Transferencia.where(sent: false).count} transferencias"
    Transferencia.where(sent: false).each do |t|
      enviado=ApiBodega.despacharOtrasBodegas(t.almacenId,t.sku,t.cantidad) #Despachar a almacenId
      t.sent=true
      t.save
    end
      Rails.logger.info "[SCHEDULE][BODEGA.ENVIARPRODUCTO]Finish at #{Time.now}, left #{Transferencia.where(sent: false).count} transferencias"
  end

  def self.pedirProducto(sku,cantidad)
    contar=0
    for i in 1..8
      if contar < cantidad #Acá a penas se recibe algo se acepta, no nos aseguramos de recibir TODO el pedido
        case i
        when 1
          url="http://integra1.ing.puc.cl/ecommerce/api/v1/pedirProducto"
          user="grupo9"
          pass="QWhiPGn2Hnm54"
          almacenId="53571e54682f95b80b786eb9"
          begin
            response=RestClient.post url,{:usuario=>user, :password=>pass, :almacenId=>almacenId, :sku=>sku, :cant=>cantidad-contar }
            if not JSON.parse(response.body).has_key?('error')
              contar=contar+JSON.parse(response.body)[:amountSent]
            end
          rescue
            Rails.logger.info "[SCHEDULE][BODEGA.PEDIRPRODUCTO]Error in conecction with group #{i}"
          end        
        when 2
          # url="http://integra2.ing.puc.cl/api/pedirProducto"
          # user="grupo9"
          # pass="QWhiPGn2Hnm54"
          # almacenId="53571e54682f95b80b786eb9"
          # begin
            # response=RestClient.post url,{:usuario=>user, :password=>pass, :almacen_id=>almacenId, :SKU=>sku, :cantidad=>cantidad-contar }
            # if not JSON.parse(response.body).has_key?('error')
              # cantidad=0
            # end
          # rescue
            # Rails.logger.info "[SCHEDULE][BODEGA.PEDIRPRODUCTO]Error in conecction with group #{i}"
          # end 
        when 3
          url="http://integra3.ing.puc.cl/api/pedirProducto"
          user="grupo9"
          pass="grupo9" #sha1
          almacenId="53571e54682f95b80b786eb9"
          begin
            response=RestClient.post url,{:usuario=>user, :password=>pass, :almacen_id=>almacenId, :SKU=>sku, :cantidad=>cantidad-contar }
            if not JSON.parse(response.body).has_key?('error')
              contar=contar+JSON.parse(response.body)[:cantidad]
            end
          rescue
            Rails.logger.info "[SCHEDULE][BODEGA.PEDIRPRODUCTO]Error in conecction with group #{i}"
          end
        when 4 #NO FUNCIONA (error: "Nombre de usuario o password invalida")
          url="http://integra4.ing.puc.cl/api/pedirProducto"
          user="grupo9"
          pass="795f5a03cad01447898fb5861de0d0af6115b0c1" #sha1
          almacenId="53571e54682f95b80b786eb9"
          begin
            response=RestClient.post url,{:usuario=>user, :password=>pass, :almacen_id=>almacenId, :SKU=>sku, :cantidad=>cantidad-contar }
            if not JSON.parse(response.body).has_key?('error')
              contar=contar+JSON.parse(response.body)[:cantidad]
            end
          rescue
            Rails.logger.info "[SCHEDULE][BODEGA.PEDIRPRODUCTO]Error in conecction with group #{i}"
          end
        when 5 #FUNCIONA
          url="http://integra5.ing.puc.cl:8080/api/v1/pedirProducto"
          user="grupo9"
          pass="JgS9I4od03" #pass
          almacenId="53571e54682f95b80b786eb9" 
          begin
            response=RestClient.post url,{:usuario=>user, :password=>pass, :almacenId=>almacenId, :sku=>sku, :cantidad=>cantidad-contar }
            if not JSON.parse(response.body).has_key?('error')
              contar=contar+JSON.parse(response.body)[:cantidad]
            end
          rescue
            Rails.logger.info "[SCHEDULE][BODEGA.PEDIRPRODUCTO]Error in conecction with group #{i}"
          end
        when 6
          # url="http://integra6.ing.puc.cl/apiGrupo/pedido"
          # user="grupo9"
          # pass="795f5a03cad01447898fb5861de0d0af6115b0c1" #sha1
          # almacenId="53571e54682f95b80b786eb9"
          # begin
            # response=RestClient.post url,{:usuario=>user, :password=>pass, :almacen_id=>almacenId, :SKU=>sku, :cantidad=>cantidad-contar }
            # if not JSON.parse(response.body).has_key?('error')
              # cantidad=0
            # end
          # rescue
            # Rails.logger.info "[SCHEDULE][BODEGA.PEDIRPRODUCTO]Error in conecction with group #{i}"
          # end
        # when 7
          # url="http:/integra7.ing.puc.cl/api/api_request"
          # user="grupo9"
          # pass="JgS9I4od03" #pass
          # almacenId="53571e54682f95b80b786eb9" 
          # begin
            # response=RestClient.get url,{:usuario=>user, :password=>pass, :almacenId=>almacenId, :sku=>sku, :cantidad=>cantidad-contar }
            # if not JSON.parse(response.body).has_key?('error')
              # contar=contar+JSON.parse(response.body)[:cantidad]
            # end
          # rescue
            # Rails.logger.info "[SCHEDULE][BODEGA.PEDIRPRODUCTO]Error in conecction with group #{i}"
          # end
        when 8 #FUNCIONA
          url="http://integra8.ing.puc.cl/api/pedirProducto"
          user="grupo9"
          almacenId="53571e54682f95b80b786eb9"
          pass="crtwjh4J" #Sebastián Charad me la dio
          begin
            response=RestClient.post url,{:usuario=>user, :password=>pass, :almacen_id=>almacenId, :SKU=>sku, :cantidad=>cantidad-contar }
            if not JSON.parse(response.body).first.has_key?('error')
              contar=contar+JSON.parse(response.body).first["cantidad"]
            end
          rescue
            Rails.logger.info "[SCHEDULE][BODEGA.PEDIRPRODUCTO]Error in conecction with group #{i}"
          end
        end
      end
    end
    return contar
  end
end
