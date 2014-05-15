require 'net/sftp'
require 'rexml/document'
include REXML
class Pedido < ActiveRecord::Base
  def self.cargar
    Net::SFTP.start('integra.ing.puc.cl','grupo9',:password=>'3045kdk') do |sftp|
      revision = (Time.now - 600)
      nombre=""
      cantidad=0
      sftp.dir.foreach("Pedidos") do |file|
        #puts file.name
        pedidoID=file.name.split('_')[1].to_i
        if file.name!=".." and file.name!="."
          if Time.at(file.attributes.mtime)>revision
            raw =sftp.download!("Pedidos/"+file.name)
            doc = Document.new(raw)
            fechaPedido=doc.elements['xml/Pedidos'].attributes['fecha']
            horaPedido=doc.elements['xml/Pedidos'].attributes['hora']
            fecha=DateTime.parse(fechaPedido+" "+horaPedido).strftime('%Y-%m-%d %H:%M')
            rut=doc.elements['xml/Pedidos/rut'].text
            direccionID=doc.elements['xml/Pedidos/direccionId'].text.to_i
            fechaLimite=Date.parse(doc.elements['xml/Pedidos/fecha'].text)
            doc.elements.each("xml/Pedidos/Pedido") do | element|
              sku=element.elements['sku'].text
              unidad=element.elements['cantidad'].attributes['unidad'] 
              cantidad=element.elements['cantidad'].text.to_f
              pedido=Pedido.new(:pedidoID=>pedidoID,:fecha => fecha,:rut=>rut,:direccionID=>direccionID,:fechaLimite=>fechaLimite,:sku=>sku,:unidad=>unidad,:cantidad=>cantidad)
              pedido.save
            end
          end
        end
      end
    end
  end
  def self.preguntarPedidosPendientes
    Pedido.all.each do |pedido|
      if pedido.fechaLimite<DateTime.now()
        pedido.destroyck
        #TODO: generar reporte de quiebre de stock
      else
        reservadosTotales=Reserva.getReservasXSKU(pedido.sku)
        reservadosCliente=Reserva.getReservasXCliente(pedido.sku,pedido.rut)
        if pedido.cantidad<[Bodega.getCantidad(pedido.sku)-reservadosTotales,0].max+reservadosCliente
          #Vender el producto
          if pedido.cantidad<reservadosCliente
            Reserva.quitarReservasXCliente(pedido.sku,pedido.rut,pedido.cantidad)
          else
            Reserva.quitarReservasXCliente(pedido.sku,pedido.rut,pedido.cantidad)
          end
        end
      end 
    end
  end
end
