require_dependency 'spree/admin/reports_controller'
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
         render "en_construccion"
      end
      def transacciones
         render "en_construccion"
      end
      def quiebres_stock
         render "en_construccion"
      end
      def bodega_pulmon
         render "en_construccion"
      end
end
