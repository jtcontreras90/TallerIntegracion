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
         render "en_construccion"
      end
      def ganancias
         render "en_construccion"
      end
      def productos_top
         render "en_construccion"
      end
      def clientes_top

         date1 = "2014-05-17T23:59:59+05:30".gsub(/T.*/, '')
         date2 = "2014-05-20T23:59:59+05:30".gsub(/T.*/, '')
         cant=10

         @q=Consultador.agg_attr_sku(Ventacliente, 'top', cant, DateTime.now-10.days,DateTime.now)
         render "en_construccion"
      end
      def transacciones
         
         date1 = "2014-05-17T23:59:59+05:30".gsub(/T.*/, '')
         date2 = "2014-05-20T23:59:59+05:30".gsub(/T.*/, '')

         @q=Consultador.total(Ventacliente,'sku',date1,date2)
         total = q[:count]

         render "en_construccion"
      end
      def quiebres_stock
         date1 = DateTime.now - 30.days
         date2 = DateTime.now

         @q=Consultador.total(Quiebres,'sku',date1,date2)
         @total = q[:count]
      end
      def bodega_pulmon

         render "en_construccion"
      end
end
