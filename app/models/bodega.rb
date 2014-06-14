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
        when 2
        when 3
        when 4
          url="http://integra4.ing.puc.cl/api/pedirProducto"
          user="grupo9"
          pass="795f5a03cad01447898fb5861de0d0af6115b0c1" #sha1
          almacenId="53571e54682f95b80b786eb9"
          begin
            response=RestClient.post url,{:usuario=>user, :password=>pass, :almacen_id=>almacenId, :SKU=>sku, :cantidad=>cantidad }
            if not JSON.parse(response.body).has_key?('error')
              cantidad=0
              break
            end
          rescue
          end
        when 5
          url="http://integra5.ing.puc.cl:8080/api/v1/pedirProducto"
          user="grupo9"
          pass="JgS9I4od03" #pass
          almacenId="53571e54682f95b80b786eb9" 
          begin
          response=RestClient.post url,{:usuario=>user, :password=>pass, :almacenId=>almacenId, :SKU=>sku, :cantidad=>cantidad }
          if not JSON.parse(response.body).has_key?('error')
            cantidad=0
            break
          end
          rescue
          end
        when 6
        when 7
        when 8
          url="http://integra8.ing.puc.cl/api/pedirProducto"
          user="grupo9"
          almacenId="53571e54682f95b80b786eb9"
          pass="5HUKt4Ltn/A3cypvmotC2swYC3Y=" #sha1 base 64
          response=RestClient.post url,{:usuario=>user, :password=>pass, :almacen_id=>almacenId, :SKU=>sku, :cantidad=>cantidad }
          if not response.body.has_key?('error')
            cantidad=0
            break
          end
        end
      end
    end
  end
end
