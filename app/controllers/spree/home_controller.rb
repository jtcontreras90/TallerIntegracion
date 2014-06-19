module Spree
  class HomeController < Spree::StoreController
    helper 'spree/products'
    respond_to :html

    def index
		@searcher = build_searcher(params)
		@products = @searcher.retrieve_products
		
		if not session.has_key?(:seteado)
			session[:seteado]={}
		end
		@products.each do |p|
			if not session[:seteado].has_key?(p.id)
				if p.refreshAttributes
					session[:seteado][p.id]=true
				end
			end
		end

		@products = @searcher.retrieve_products
		@taxonomies = Spree::Taxonomy.includes(root: :children)
    end


  end
end
