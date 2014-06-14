require_dependency 'spree/admin/reports_controller'
require 'date'
require 'json'
Spree::Admin::ReportsController.class_eval do
    ADVANCED_REPORTS ||= {}
    
      Spree::Admin::ReportsController.add_available_report!(:ingresos,"Ingresos")
      Spree::Admin::ReportsController.add_available_report!(:ganancias,"Ganancias")
      Spree::Admin::ReportsController.add_available_report!(:productos_top,"Productos Top")
      Spree::Admin::ReportsController.add_available_report!(:clientes_top,"Clientes VIP")
      Spree::Admin::ReportsController.add_available_report!(:transacciones,"Transacciones")
      Spree::Admin::ReportsController.add_available_report!(:quiebres_stock,"Quiebres de Stock")
      Spree::Admin::ReportsController.add_available_report!(:bodega_pulmon,"Costo Bodega Pulmón")
      Spree::Admin::ReportsController.add_available_report!(:tweets,"Tweets de la compañía")
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
         @idClientes=@idClientes.to_json
         @ingresosClientes=@ingresosClientes.to_json
         @skuProductos=@skuProductos.to_json
         @ingresosProductos=@ingresosProductos.to_json
         @months=@months.to_json
         @series=[{:name=>"Ingresos Mensuales", :data=>ingresosCLientesAnual}].to_json
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
         @idClientes=@idClientes.to_json
         @ingresosClientes=@ingresosClientes.to_json
         @skuProductos=@skuProductos.to_json
         @ingresosProductos=@ingresosProductos.to_json
         @months=@months.to_json
         @series=[{:name=>"Ganancias Mensuales", :data=>gananciasCLientesAnual}].to_json
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
      def tweets
      end
end
