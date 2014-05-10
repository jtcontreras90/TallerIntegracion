class ApiController < ApplicationController

	def preguntarStock
		@bodega=Bodega.find_by_username(params[:username])
		return render :json => {status: 404, message: "User Not Found"}, status: :not_found unless @bodega
		return render :json => {status: 401, message: "Invalid Credentials"}, status: :unauthorized unless @bodega.password==params[:password]
		variant=Spree::Variant.find_by_sku(params[:sku])
		return render :json => {status: 404, message: "Product with SKU '#{params[:sku]}' Not Found"}, status: :not_found unless variant
		#Si existe la variante, entonces existe el producto

		#Aquí interviene Ignacio Yousef viendo la cantidad disponible de producto para el SKU dado
		#APIBodega.GetStock(params[:SKU])

		render :json => {status: 200, response: {sku: params[:sku], cantidad: 12}}
	end

	def enviarProducto
		@bodega=Bodega.find_by_username(params[:username])
		return render :json => {status: 404, message: "User Not Found"}, status: :not_found unless @bodega
		return render :json => {status: 401, message: "Invalid Credentials"}, status: :unauthorized unless @bodega.password==params[:password]
		variant=Spree::Variant.find_by_sku(params[:sku])
		return render :json => {status: 404, message: "Product with SKU '#{params[:sku]}' Not Found"}, status: :not_found unless variant

		#Aquí interviene Ignacio Yousef viendo la cantidad disponible de producto para el SKU dado
		#disponible=APIBodega.GetStock(params[:SKU])

		enviado=0

		#if disponible > params[:cantidad]
		# enviado=APIBodega.enviar(params[:SKU],params[:cantidad],params[:almacenId])
		#else
		# envieado=APIBodega.enviar(params[:SKU],disponible,params[:almacenId])
		#end

		render :json => {status: 200, response: {sku: params[:sku], cantidad: enviado}}

	end

end
