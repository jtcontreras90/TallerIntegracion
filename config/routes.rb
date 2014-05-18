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
  end

  scope :path => "/api" do
    get "/disponibles/:username/:password/:sku" => "api#preguntarStock" #Me permite obtener el stock disponible
    post  "/pedirProducto/:username/:password/:sku"  => "api#enviarProducto" #Me permite enviar producto a la bodega dada
  end

end
