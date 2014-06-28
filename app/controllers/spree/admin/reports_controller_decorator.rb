require_dependency 'spree/admin/reports_controller'
require 'date'
require 'json'
Spree::Admin::ReportsController.class_eval do
    ADVANCED_REPORTS ||= {}
    
      Spree::Admin::ReportsController.add_available_report!(:tweets,"Tweets de la compañía")
      Spree::Admin::ReportsController.add_available_report!(:mapa,"Mapa de pedidos")
      Spree::Admin::ReportsController.add_available_report!(:ingresos,"Ingresos")
      Spree::Admin::ReportsController.add_available_report!(:ganancias,"Ganancias")
      Spree::Admin::ReportsController.add_available_report!(:productos_top,"Productos Top")
      Spree::Admin::ReportsController.add_available_report!(:clientes_top,"Clientes VIP")
      Spree::Admin::ReportsController.add_available_report!(:transacciones,"Transacciones")
      Spree::Admin::ReportsController.add_available_report!(:quiebres_stock,"Quiebres de Stock")
      Spree::Admin::ReportsController.add_available_report!(:bodega_pulmon,"Costo Bodega Pulmón")

      def tweets
      end

      def map
        pedidoID=nil
        @paquetesPedidos=[]
        @h=Pedido.all.map{|x| x.pedidoID}.uniq.count
        pedidos=Pedido.order('created_at desc').map{|x| x.pedidoID}.uniq[params[:offset].to_i,10]
        if pedidos
          pedidos.each do |p|
            a={}
            b=[]
            parcial = false
            Pedido.where(pedidoID: p).each_with_index do |pedido,i|
              if i==0
                a['color']="green"
                a['nombreCliente']=pedido.rut
                a['direccion']=pedido.direccion
                a['fechaLimite']=pedido.fechaLimite.strftime('%d/%m/%Y')
                
              end
              c={}
              c['cantidadSolicitada']=pedido.cantidad
              c['cantidadEnviada']=pedido.cant_vendida
              c['sku']= pedido.sku
              c['quiebre']=pedido.quebrado
              b<<c
              if pedido.quebrado
                a['color']="red"
              else
                parcial = true
              end

              if pedido.cantidad > pedido.cant_vendida
                a['color']="yellow"

              end

            end
            a['pedido']=b
            @paquetesPedidos<<a
          end
        end
      end


      def ingresos
         hoy=DateTime.now
         date1 = hoy - hoy.day.days
         date2 = hoy
         @q=Consultador.agg_attr_sku(Ventaproducto, 'sum', 'ingresos', date1, date2)
         @qq=Consultador.agg_attr_sku(Ventacliente, 'sum', 'ingresos', date1, date2)
         @qqq=Consultador.total(Ventacliente,'ingresos',date1, date2)
         @skuProductos=[]
         @ingresosProductos=[]
         @q.each do |c|
          @skuProductos.append(c._id)
          @ingresosProductos.append(c.sum_ingresos)
         end
         @idClientes=[]
         @ingresosClientes=[]
         @qq.each do |c|
          @idClientes.append(c._id)
          @ingresosClientes.append(c.sum_ingresos)
         end
         ingresosCLientesAnual=[]
         @months=[]
         I18n.default_locale = :es
         ingresosCLientesAnual.append(Consultador.total(Ventacliente,'ingresos',hoy-hoy.day.days, hoy))
         @months.append(I18n.l Date.today-(11).months, :format => "%b")
         for i in 2..12
           @months.append(I18n.l Date.today-(12-i).months, :format => "%b")
           date3=hoy-(i-1).months-hoy.day.days
           date4=hoy-i.months-hoy.day.days
           c=Consultador.total(Ventacliente,'ingresos',date3, date4)
           ingresosCLientesAnual.append(c[:sum])
         end
         
         gananciasCLientesAnual=Venta.select(:ingreso)
         ganancias=gananciasCLientesAnual.collect{|g| g.ingreso}.to_json
         @idClientes=@idClientes.to_json
         @ingresosClientes=@ingresosClientes.to_json
         @skuProductos=@skuProductos.to_json
         @ingresosProductos=@ingresosProductos.to_json
         @months=@months.to_json
         @series=[{:name=>"Ingresos Diarios", :data=>gananciasCLientesAnual, :pointStart=> 1.year.ago.to_i*1000, :pointInterval=> 24 * 3600 * 1000}].to_json
      end
      
      def ganancias
         hoy=DateTime.now
         date1 = hoy - hoy.day.days
         date2 = hoy
         @q=Consultador.agg_attr_sku(Ventaproducto, 'sum', 'utilidades', date1,date2)
         @qq=Consultador.agg_attr_sku(Ventacliente, 'sum', 'utilidades', date1,date2)
         @qqq=Consultador.total(Ventacliente,'utilidades',date1,date2)
         @skuProductos=[]
         @gananciasProductos=[]
         @q.each do |c|
          @skuProductos.append(c._id)
          @gananciasProductos.append(c.sum_utilidades)
         end
         @idClientes=[]
         @gananciasClientes=[]
         @qq.each do |c|
          @idClientes.append(c._id)
          @gananciasClientes.append(c.sum_utilidades)
         end
         gananciasCLientesAnual=[]
         @months=[]
         I18n.default_locale = :es
         hoy=DateTime.now
         gananciasCLientesAnual.append(Consultador.total(Ventacliente,'utilidades',hoy-hoy.day.days, hoy))
         @months.append(I18n.l Date.today-(11).months, :format => "%b")
         for i in 2..12
           @months.append(I18n.l Date.today-(12-i).months, :format => "%b")
           date3=hoy-(i-1).months-hoy.day.days
           date4=hoy-i.months-hoy.day.days
           c=Consultador.total(Ventacliente,'utilidades',date3, date4)
           gananciasCLientesAnual.append(c[:sum])
         end
         gananciasCLientesAnual=Venta.select(:utilidad)
         ganancias=gananciasCLientesAnual.collect{|g| g.utilidad}.to_json
         @idClientes=@idClientes.to_json
         @ingresosClientes=@ingresosClientes.to_json
         @skuProductos=@skuProductos.to_json
         @ingresosProductos=@ingresosProductos.to_json
         @months=@months.to_json
         @series=[{:name=>"Ganancias Diarias", :data=>gananciasCLientesAnual, :pointStart=> 1.year.ago.to_i*1000, :pointInterval=> 24 * 3600 * 1000}].to_json
      end
      
      def productos_top
         hoy = DateTime.now
         date1 = hoy - hoy.day.days
         date2 = hoy
         cant=10

         @q=Consultador.agg_attr_sku(Ventaproducto, 'top', cant, date1, date2)
      end
      def clientes_top
         hoy = DateTime.now
         date1 = hoy - hoy.day.days
         date2 = hoy
         cant=10

         @q=Consultador.agg_attr_sku(Ventacliente, 'top', cant, date1,date2)
      end
      def transacciones
         hoy = DateTime.now         
         date1 = hoy - hoy.day.days
         date2 = hoy
         pedidos=[]
         Pedido.all.order("fecha").each do |p|
           if p.enviado
             pedidos.append(:y=>p.cantidad,:quebrado=>p.cant_quebrada,:vendido=>p.cant_vendida,:color=>'#0066FF')
           elsif p.quebrado
             pedidos.append(:y=>p.cantidad,:quebrado=>p.cant_quebrada,:vendido=>p.cant_vendida,:color=>'#FFFF00')
           else
             pedidos.append(:y=>p.cantidad,:quebrado=>p.cant_quebrada,:vendido=>p.cant_vendida,:color=>'#0000FF')
           end
         end
         @series=[{:name=>"Ganancias Diarias", :data=>pedidos, :pointStart=> Pedido.all.order("fecha").first.created_at.to_i*1000}].to_json
         @q=Consultador.total(Ventacliente,'sku',date1,date2)
         @total = @q[:count]

      end
      def quiebres_stock
         hoy = DateTime.now         
         date1 = hoy - hoy.day.days
         date2 = hoy

         @q=Consultador.total(Quiebre,'sku',date1,date2)
         @total = @q[:count]
      end
      def bodega_pulmon
         hoy = DateTime.now         
         date1 = hoy - hoy.day.days
         date2 = hoy
         
         @q=Consultador.total(Costobodegapulmon,'costos',date1,date2)
         @qq=Consultador.total(Costobodegapulmon,'cantidad_productos',date1,date2)
         @total = @qq[:sum]
         @sum = @q[:sum]
      end
end
