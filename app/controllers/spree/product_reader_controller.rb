module Spree
	class ProductReaderController < Spree::Admin::BaseController
		require 'json'

		def upload_file
			# File.open(Rails.root.join('public', 'productos.json'), 'wb') do |file|
			# 	file.write(params['file-0'].tempfile.read)
			# end
			render json: params['file-0'].tempfile.read
		end

		def upload
			var={}
			m=Spree::Taxonomy.where(name: "Marca").first.id
			c=Spree::Taxonomy.where(name: "Categoría").first.id
			mt=Spree::Taxon.where(name: "Marca", taxonomy_id: m).first.id
			ct=Spree::Taxon.where(name: "Categoría", taxonomy_id: c).first.id

			v= Spree::Variant.where(sku: params[:sku]).first
			if (v and not v.product) or not v
				if v
					v.delete
				end
				p=Spree::Product.new
				p.name=params[:modelo]
				p.sku=params[:sku]
				p.description=params[:descripcion]
				p.price=params[:precio][:internet]
				p.internet_price=params[:precio][:internet]
				p.available_on=Time.now
				p.tax_category_id=1
				p.shipping_category_id=1
				p.normal_price=params[:precio][:normal]
				if p.save
					i=Spree::Image.create({:attachment => open(URI.parse(params[:imagen])),:viewable => p.master})
					s=p.stock_items.first
					s['count_on_hand']=0
					s.backorderable=false
					s.save
					var['product']=1
				else
					var['product']=-1
				end
			else
				var['product']=0
			end

			t=Spree::Taxon.where(name: params[:marca]).first
			if not t
				t=Spree::Taxon.create(name: params[:marca], parent_id: mt, taxonomy_id: m)
				if t
					var['marca']=1
				else
					var['marca']=-1
				end
			else
				var['marca']=0
			end

			begin
				p.taxons << t
				p.save
			rescue
			end

			var['categorias']=[]
			params[:categorias].each do |cat|
				t=Spree::Taxon.where(name: cat).first
				if not t
					t=Spree::Taxon.create(name: cat, parent_id: ct, taxonomy_id: c)
					if t
						var['categorias']<<{name: cat, categoria: 1 }
					else
						var['categorias']<<{name: cat, categoria: -1 }					
					end
				else
					var['categorias']<<{name: cat, categoria: 0 }
				end

				#if t and p and not t.products.where(product_id: p.id).count > 0
				begin
					p.taxons << t
					p.save
				rescue
				end
			end


			# puts "#{params[:sku]}"
			# puts "#{params[:marca]}"
			# puts "#{params[:modelo]}"
			# puts "#{params[:precio][:normal]}"
			# puts "#{params[:precio][:internet]}"
			# puts "#{params[:imagen]}"
			# puts "Categorías:"
			# params[:categorias].each do |c|
			# 	puts "\t #{c}"
			# end

		  	render json: var.to_json
		end

	end
end
