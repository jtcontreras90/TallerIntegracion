class ApiController < ApplicationController

	skip_before_filter :verify_authenticity_token  
	#/disponibles/:username/:password/:sku
	def preguntarStock
		@bodega=Bodega.find_by_username(params[:username])
		return render :json => {status: 404, message: "User Not Found"}, status: :not_found unless @bodega
		return render :json => {status: 401, message: "Invalid Credentials"}, status: :unauthorized unless @bodega.password==params[:password]
		variant=Spree::Variant.find_by_sku(params[:sku])
		return render :json => {status: 404, message: "Product with SKU '#{params[:sku]}' Not Found"}, status: :not_found unless variant
		#Si existe la variante, entonces existe el producto

		disponible=ApiBodega.obtenerStock(params[:sku]) #Stock del producto con el sku dado
		costo=Pricing.precioTransferenciaBySKU(params[:sku])

		render :json => {status: 200, response: {sku: params[:sku], cantidad: disponible, costo: costo}}
	end


	def enviarProducto
		@bodega=Bodega.find_by_username(params[:username])
		return render :json => {status: 404, message: "User Not Found"}, status: :not_found unless @bodega
		return render :json => {status: 401, message: "Invalid Credentials"}, status: :unauthorized unless @bodega.password==params[:password]
		variant=Spree::Variant.find_by_sku(params[:sku])
		return render :json => {status: 404, message: "Product with SKU '#{params[:sku]}' Not Found"}, status: :not_found unless variant

		disponible=ApiBodega.obtenerStock(params[:sku]) #Stock del producto con el sku dado

		enviado=0
		costo=0

		if disponible >= params[:cantidad].to_i and params[:cantidad].to_i >0
			costo=Pricing.precioTransferenciaBySKU(params[:sku])*params[:cantidad].to_i
			t=Transferencia.new
			t.almacenId=params[:almacenId]
			t.sku=params[:sku]
			t.cantidad=params[:cantidad].to_i
			t.costotransferencia=costo
			t.sent=false
			t.bodega=@bodega
			t.save
			enviado=params[:cantidad].to_i
			# enviado=ApiBodega.despacharOtrasBodegas(params[:almacenId],params[:sku],params[:cantidad].to_i) #Despachar a almacenId
		end

		render :json => {status: 200, response: {sku: params[:sku], cantidad: enviado, costo: costo}}

	end

end
