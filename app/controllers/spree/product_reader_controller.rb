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
			m=Spree::Taxonomy.where(name: "Marca").first.id
			c=Spree::Taxonomy.where(name: "Categoría").first.id
			mt=Spree::Taxon.where(name: "Marca", taxonomy_id: m).first.id
			ct=Spree::Taxon.where(name: "Categoría", taxonomy_id: c).first.id

			p= Spree::Variant.where(sku: params[:sku]).first
			if not p
				p=Spree::Product.new
				p.name=params[:modelo]
				p.sku=params[:sku]
				p.description=params[:descripcion]
				p.price=params[:precio][:internet]
				p.available_on=Time.now
				p.tax_category_id=1
				p.shipping_category_id=1
				p.normal_price=params[:precio][:normal]

				t=Spree::Taxon.where(name: params[:marca]).first
				if not t
					t=Spree::Taxon.create(name: params[:marca], parent_id: mt, taxonomy_id: m)
				end
				p.taxons << t

				

				params[:categorias].each do |cat|
					t=Spree::Taxon.where(name: cat).first
					if not t
						t=Spree::Taxon.create(name: cat, parent_id: ct, taxonomy_id: c)
					end
					p.taxons << t
				end

				p.save

				i=Spree::Image.create!({:attachment => open(URI.parse(params[:imagen])),:viewable => p.master})
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

		  	render json: "OK".to_json
		end

	end
end
