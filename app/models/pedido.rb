require 'net/sftp'
require 'rexml/document'

include REXML
class Pedido < ActiveRecord::Base
  belongs_to :venta, :class_name => "Venta", :foreign_key => 'pedido_id'
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
          end
        end
      end
    end
  end

  def self.preguntarPedidosPendientes
    Pedido.all.each do |pedido|
      if not pedido.enviado and not pedido.quebrado
        if pedido.fechaLimite<DateTime.now()
          Quiebre.agregar(:fecha=> DateTime.now(),:sku_producto=>pedido, :rut_cliente=>pedido.rut)
        pedido.quebrado=true
        pedido.save
        #pedido.destroy()
        else
          puts "Llego aqui"
          reservadosTotales=Reserva.getReservasXSKU(pedido.sku)
          reservadosCliente=Reserva.getReservasXCliente(pedido.sku,pedido.rut)
          if pedido.cantidad<ApiBodega.obtenerStock(pedido.sku) and pedido.cantidad<[ApiBodega.obtenerStock(pedido.sku)-reservadosTotales,0].max+reservadosCliente
            #Vender el producto
            variant=Spree::Variant.where(:sku=>pedido.sku).first()
            venta=Venta.new(:spree_variant_id=>variant.id,
            :utilidad=>0,
            :ingreso=>0,
            :pedido_id=>pedido.id,
            :fecha=>DateTime.now())
            venta.save
            Reserva.quitarReservasXCliente(pedido.sku,pedido.rut,[pedido.cantidad,reservadosCliente].min)
            pedido.enviado=true
            pedido.save
            puts "incluso termino"
          #pedido.destroy()
          end
        end
      end
    end
  end
end