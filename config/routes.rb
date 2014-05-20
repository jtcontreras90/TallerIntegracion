TallerIntegracion::Application.routes.draw do

  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being the default of "spree"
  mount Spree::Core::Engine, :at => '/'
  Spree::Core::Engine.routes.draw do
    get "/admin/upload" => "product_reader#index", :as => :admin_import
    post "/admin/upload" => "product_reader#upload"
    post "/admin/upload_file" => "product_reader#upload_file", :as => :admin_import_file
    match '/admin/reports/ingresos' => 'admin/reports#ingresos', :via => [:get, :post], :as =>'ingresos_admin_reports'
    match '/admin/reports/ganancias' => 'admin/reports#ganancias', :via => [:get, :post], :as =>'ganancias_admin_reports'
    match '/admin/reports/bodega_pulmon' => 'admin/reports#bodega_pulmon', :via => [:get, :post], :as =>'bodega_pulmon_admin_reports'
    match '/admin/reports/productos_top' => 'admin/reports#productos_top', :via => [:get, :post], :as =>'productos_top_admin_reports'
    match '/admin/reports/clientes_top' => 'admin/reports#clientes_top', :via => [:get, :post], :as =>'clientes_top_admin_reports'
    match '/admin/reports/transacciones' => 'admin/reports#transacciones', :via => [:get, :post], :as =>'transacciones_admin_reports'
    match '/admin/reports/quiebres_stock' => 'admin/reports#quiebres_stock', :via => [:get, :post], :as =>'quiebres_stock_admin_reports'
  end

  scope :path => "/api" do
    get "/disponibles/:username/:password/:sku" => "api#preguntarStock" #Me permite obtener el stock disponible
    post  "/pedirProducto/:username/:password/:sku"  => "api#enviarProducto" #Me permite enviar producto a la bodega dada
  end

end
