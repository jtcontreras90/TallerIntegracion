require 'net/sftp'
require 'rexml/document'

include REXML
class Pedido < ActiveRecord::Base

  belongs_to :venta, :class_name => "Venta", :foreign_key => 'pedido_id'
  def self.cargar(less=2100)
    Rails.logger.info "[SCHEDULE][PEDIDO.CARGAR]Begin at #{Time.now}"
    Net::SFTP.start('integra.ing.puc.cl','grupo9',:password=>'3045kdk') do |sftp|
      revision = (Time.now - less)
      puts revision
      nombre=""
      cantidad=0
      sftp.dir.foreach("Pedidos") do |file|
      #puts file.name
        pedidoID=file.name.split('_')[1].to_i
        if Pedido.where(:pedidoID=>pedidoID).count == 0
          if file.name!=".." and file.name!="."
            if Time.at(file.attributes.mtime)>revision
              Rails.logger.info "[SCHEDULE][PEDIDO.CARGAR]SFTP processing: #{file.name}"
              raw =sftp.download!("Pedidos/"+file.name)
              doc = Document.new(raw)
              fechaPedido=doc.elements['xml/Pedidos'].attributes['fecha']
              horaPedido=doc.elements['xml/Pedidos'].attributes['hora']
              fecha=DateTime.parse(fechaPedido+" "+horaPedido).strftime('%Y-%m-%d %H:%M')
              rut=doc.elements['xml/Pedidos/rut'].text
              direccionID=doc.elements['xml/Pedidos/direccionId'].text.to_i
              vtiger=Vtiger.new
              if vtiger.direccionByRutAndDireccionId(rut,direccionID)
                Rails.logger.info "[SCHEDULE][PEDIDO.CARGAR]Pedido added from file #{file.name}"
                fechaLimite=Date.parse(doc.elements['xml/Pedidos/fecha'].text)
                doc.elements.each("xml/Pedidos/Pedido") do | element|
                  sku=element.elements['sku'].text.strip
                  unidad=element.elements['cantidad'].attributes['unidad']
                  cantidad=element.elements['cantidad'].text.to_f
                  direccion=vtiger.direccionByRutAndDireccionId(rut,direccionID)
                  direccion=direccion['calle']+', '+direccion['ciudad']+', '+direccion['region']
                  pedido=Pedido.new(:pedidoID=>pedidoID,:fecha => fecha,:rut=>rut,:direccionID=>direccionID,:fechaLimite=>fechaLimite,:sku=>sku,:unidad=>unidad,:cantidad=>cantidad, :enviado=>false, :quebrado=>false, :direccion=>direccion, :cant_vendida=>0, :cant_quebrada=>0)
                  pedido.save
                end
              end
            vtiger.logout
            end
          end
        end
      end
    end
    Rails.logger.info "[SCHEDULE][PEDIDO.CARGAR]Finish at #{Time.now}"
  end

  def self.preguntarPedidosPendientes
    Rails.logger.info "[SCHEDULE][PEDIDO.PREGUNTARPEDIDOSPENDIENTES]Begin at #{Time.now}"
    Pedido.all.each do |pedido|
      if not pedido.enviado and not pedido.quebrado
        sku=pedido.sku.strip
        precios=Pricing.findBySKU(sku)
        reservadosTotales=Reserva.getReservasXSKU(sku)
        reservadosCliente=Reserva.getReservasXCliente(sku,pedido.rut)
        stockDisponible=ApiBodega.obtenerStock(sku)
        stockDisponibleCliente=[[stockDisponible-reservadosTotales,0].max+reservadosCliente,stockDisponible].min
        if pedido.fechaLimite<DateTime.now()
          Quiebre.agregar(DateTime.now,pedido.sku,pedido.rut)
          pedido.quebrado=true
          if pedido.cant_vendida
          pedido.cant_quebrada=pedido.cantidad-pedido.cant_vendida
          else
          pedido.cant_quebrada=pedido.cantidad
          pedido.cant_vendida=0
          end
          pedido.save
          if pedido.cant_vendida>0 and not pedido.enviado
            #Vender el producto
            variant=Spree::Variant.where(sku: sku).first()
            if variant==nil
              venta=Venta.create(:spree_variant_id=>0,
              :utilidad=>(precios.precio-precios.costo_producto)*pedido.cant_vendida,
              :ingreso=>precios.precio*pedido.cant_vendida,
              :pedido_id=>pedido.id,
              :fecha=>DateTime.now())
            else
              venta=Venta.create(:spree_variant_id=>variant.id,
              :utilidad=>(precios.precio-precios.costo_producto)*pedido.cant_vendida,
              :ingreso=>precios.precio*pedido.cant_vendida,
              :pedido_id=>pedido.id,
              :fecha=>DateTime.now())
            end
          end
        else
          puts "Sku: #{pedido.sku}"
          # puts "Cantidad pedida: #{pedido.cantidad}"
          # puts "Cantidad disponible: #{stockDisponible}"
          # puts "Cantidad disponible para el cliente: #{[stockDisponible-reservadosTotales,0].max+reservadosCliente}"
          # puts "pedido.cantidad<stockDisponible: #{pedido.cantidad<stockDisponible}"
          # puts "pedido.cantidad<[stockDisponible-reservadosTotales,0].max+reservadosCliente #{pedido.cantidad<[stockDisponible-reservadosTotales,0].max+reservadosCliente}"
          if stockDisponibleCliente<(pedido.cantidad-pedido.cant_vendida)
            Bodega.pedirProducto(pedido.sku,(pedido.cantidad-pedido.cant_vendida)-stockDisponibleCliente)
            cantidadVendida=stockDisponibleCliente
            if cantidadVendida>=pedido.cantidad-pedido.cant_vendida
              pedido.cant_vendida=pedido.cantidad
              pedido.enviado=true
              variant=Spree::Variant.where(sku: sku).first()
              if variant==nil
                venta=Venta.create(:spree_variant_id=>0,
                :utilidad=>(precios.precio-precios.costo_producto)*pedido.cant_vendida,
                :ingreso=>precios.precio*pedido.cantidad,
                :pedido_id=>pedido.id,
                :fecha=>DateTime.now())
              else
                venta=Venta.create(:spree_variant_id=>variant.id,
                :utilidad=>(precios.precio-precios.costo_producto)*pedido.cant_vendida,
                :ingreso=>precios.precio*pedido.cantidad,
                :pedido_id=>pedido.id,
                :fecha=>DateTime.now())
              end
            end
            pedido.cant_vendida=pedido.cant_vendida+cantidadVendida
          else
            cantidadVendida=pedido.cantidad-pedido.cant_vendida
            pedido.cant_vendida=pedido.cantidad
            pedido.enviado=true
            variant=Spree::Variant.where(sku: sku).first()
            if variant==nil
              venta=Venta.create(:spree_variant_id=>0,
              :utilidad=>(precios.precio-precios.costo_producto)*pedido.cant_vendida,
              :ingreso=>precios.precio*pedido.cantidad,
              :pedido_id=>pedido.id,
              :fecha=>DateTime.now())
            else
              venta=Venta.create(:spree_variant_id=>variant.id,
              :utilidad=>(precios.precio-precios.costo_producto)*pedido.cant_vendida,
              :ingreso=>precios.precio*pedido.cantidad,
              :pedido_id=>pedido.id,
              :fecha=>DateTime.now())
            end
          end
          Rails.logger.info "[SCHEDULE][PEDIDO.PREGUNTARPEDIDOSPENDIENTES]Processing Pedido with id #{pedido.pedidoID}"
          Reserva.quitarReservasXCliente(sku,pedido.rut,[cantidadVendida,reservadosCliente].min)
          if cantidadVendida>0
            ApiBodega.despacharProducto(sku, cantidadVendida, pedido.direccion, precios.precio, pedido.pedidoID)
          end
          pedido.save
          Rails.logger.info "[SCHEDULE][PEDIDO.PREGUNTARPEDIDOSPENDIENTES]Sold Pedido with id #{pedido.pedidoID}"
        end
      end
    end
    Rails.logger.info "[SCHEDULE][PEDIDO.PREGUNTARPEDIDOSPENDIENTES]Finish at #{Time.now}"
  end
end
