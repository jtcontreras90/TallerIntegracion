require_dependency 'spree/admin/reports_controller'
require 'date'
Spree::Admin::ReportsController.class_eval do
    ADVANCED_REPORTS ||= {}
    
      Spree::Admin::ReportsController.add_available_report!(:ingresos,"Ingresos")
      Spree::Admin::ReportsController.add_available_report!(:ganancias,"Ganancias")
      Spree::Admin::ReportsController.add_available_report!(:productos_top,"Productos Top")
      Spree::Admin::ReportsController.add_available_report!(:clientes_top,"Clientes VIP")
      Spree::Admin::ReportsController.add_available_report!(:transacciones,"Transacciones")
      Spree::Admin::ReportsController.add_available_report!(:quiebres_stock,"Quiebres de Stock")
      Spree::Admin::ReportsController.add_available_report!(:bodega_pulmon,"Costo Bodega Pulmón")
      def ingresos
         date1 = DateTime.now - 30.days
         date2 = DateTime.now
         @q=Consultador.agg_attr_sku(Ventaproducto, 'sum', 'ingresos', date1,date2)
         @qq=Consultador.agg_attr_sku(Ventacliente, 'sum', 'ingresos', date1,date2)
         @qqq=Consultador.total(Ventacliente,'ingresos',date1,date2)
      end
      
      def ganancias
         date1 = DateTime.now - 30.days
         date2 = DateTime.now
         @q=Consultador.agg_attr_sku(Ventaproducto, 'sum', 'utilidades', date1,date2)
         @qq=Consultador.agg_attr_sku(Ventacliente, 'sum', 'utilidades', date1,date2)
         @qqq=Consultador.total(Ventacliente,'utilidades',date1,date2)
      end
      
      def productos_top
         date1 = DateTime.now - 30.days
         date2 = DateTime.now
         cant=10

         @q=Consultador.agg_attr_sku(Ventaproducto, 'top', cant, date1,date2)
      end
      def clientes_top

         date1 = DateTime.now - 30.days
         date2 = DateTime.now
         cant=10

         @q=Consultador.agg_attr_sku(Ventacliente, 'top', cant, date1,date2)
      end
      def transacciones
         
         date1 = DateTime.now - 30.days
         date2 = DateTime.now

         @q=Consultador.total(Ventacliente,'sku',date1,date2)
         @total = @q[:count]

      end
      def quiebres_stock
         date1 = DateTime.now - 30.days
         date2 = DateTime.now

         @q=Consultador.total(Quiebre,'sku',date1,date2)
         @total = @q[:count]
      end
      def bodega_pulmon
         date1 = DateTime.now - 30.days
         date2 = DateTime.now

         @q=Consultador.total(Costobodegapulmon,'costos',date1,date2)
         @qq=Consultador.total(Costobodegapulmon,'cantidad_productos',date1,date2)
         @total = @qq[:sum]
         @sum = @q[:sum]
      end
end
