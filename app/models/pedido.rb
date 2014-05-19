require 'net/sftp'
require 'rexml/document'

include REXML
class Pedido < ActiveRecord::Base

  belongs_to :venta, :class_name => "Venta", :foreign_key => 'pedido_id'
  def self.cargar
    Rails.logger.info "[SCHEDULE][PEDIDO.CARGAR]Begin at #{Time.now}"
    Net::SFTP.start('integra.ing.puc.cl','grupo9',:password=>'3045kdk') do |sftp|
      revision = (Time.now - 600)
      nombre=""
      cantidad=0
      sftp.dir.foreach("Pedidos") do |file|
      #puts file.name
        pedidoID=file.name.split('_')[1].to_i
        if file.name!=".." and file.name!="."
          #if Time.at(file.attributes.mtime)>revision
            raw =sftp.download!("Pedidos/"+file.name)
            doc = Document.new(raw)
            fechaPedido=doc.elements['xml/Pedidos'].attributes['fecha']
            horaPedido=doc.elements['xml/Pedidos'].attributes['hora']
            fecha=DateTime.parse(fechaPedido+" "+horaPedido).strftime('%Y-%m-%d %H:%M')
            rut=doc.elements['xml/Pedidos/rut'].text
            direccionID=doc.elements['xml/Pedidos/direccionId'].text.to_i
            vtiger=Vtiger.new
            if vtiger.direccionByRutAndDireccionId(rut,direccionID)
              fechaLimite=Date.parse(doc.elements['xml/Pedidos/fecha'].text)
              doc.elements.each("xml/Pedidos/Pedido") do | element|
                sku=element.elements['sku'].text
                unidad=element.elements['cantidad'].attributes['unidad']
                cantidad=element.elements['cantidad'].text.to_f
                pedido=Pedido.new(:pedidoID=>pedidoID,:fecha => fecha,:rut=>rut,:direccionID=>direccionID,:fechaLimite=>fechaLimite,:sku=>sku,:unidad=>unidad,:cantidad=>cantidad, :enviado=>false, :quebrado=>false)
                pedido.save
              end
            end
            vtiger.logout
          #end
        end
      end
    end
    Rails.logger.info "[SCHEDULE][PEDIDO.CARGAR]Finish at #{Time.now}"
  end

  def self.preguntarPedidosPendientes
    Rails.logger.info "[SCHEDULE][PEDIDO.PREGUNTARPEDIDOSPENDIENTES]Begin at #{Time.now}"
    Pedido.all.each do |pedido|
      if not pedido.enviado and not pedido.quebrado
        if pedido.fechaLimite<DateTime.now()
          Quiebre.agregar(DateTime.now,pedido.sku,pedido.rut)
          pedido.quebrado=true
          pedido.save
          
        else
          puts "otro hola"
          reservadosTotales=Reserva.getReservasXSKU(pedido.sku)
          reservadosCliente=Reserva.getReservasXCliente(pedido.sku,pedido.rut)
          stockDisp=ApiBodega.obtenerStock(pedido.sku)
          puts pedido.cantidad<stockDisp
          puts pedido.cantidad
          puts stockDisp
          puts pedido.sku
          puts pedido.cantidad<[stockDisp-reservadosTotales,0].max+reservadosCliente
          if pedido.cantidad<stockDisp and pedido.cantidad<[stockDisp-reservadosTotales,0].max+reservadosCliente
            #Vender el producto
            puts "hola"
            variant=Spree::Variant.where(:sku=>pedido.sku).first()
            precios=Pricing.findBySKU(pedido.sku)
            venta=Venta.new(:spree_variant_id=>variant.id,
            :utilidad=>precios['Precio']-precios['Costo Producto'],
            :ingreso=>precios['Precio'],
            :pedido_id=>pedido.id,
            :fecha=>DateTime.now())
            venta.save
            Reserva.quitarReservasXCliente(pedido.sku,pedido.rut,[pedido.cantidad,reservadosCliente].min)
            vtiger=Vtiger.new
            direccion=vtiger.direccionByRutAndDireccionId(pedido.rut,pedido.direccionID)
            ApiBodega.despacharProducto(pedido.sku, pedido.cantidad,direccion['calle']+', '+direccion['ciudad']+', '+direccion['region'], precios['Precio'], pedido.id)
            vtiger.logout
            pedido.enviado=true
            pedido.save
          end
        end
      end
    end
    Rails.logger.info "[SCHEDULE][PEDIDO.PREGUNTARPEDIDOSPENDIENTES]Finish at #{Time.now}"
  end
end