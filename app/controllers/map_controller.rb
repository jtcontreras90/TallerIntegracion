class MapController < ApplicationController
	def maps
		pedidoID=nil
		@paquetesPedidos=[]
		@h=Pedido.all.map{|x| x.pedidoID}.uniq.count
		pedidos=Pedido.order('created_at desc').map{|x| x.pedidoID}.uniq[params[:offset].to_i,10]
		if pedidos
			pedidos.each do |p|
				a={}
				b=[]
				parcial = false
				Pedido.where(pedidoID: p).each_with_index do |pedido,i|
					if i==0
						a['color']="green"
						a['nombreCliente']=pedido.rut
						a['direccion']=pedido.direccion
						a['fecha_limite']=pedido.fechaLimite.strftime('%d/%m/%Y')
					end
					c={}
					c['cantidadSolicitada']=pedido.cantidad
					c['cantidadEnviada']=pedido.cant_vendida
					c['sku']= pedido.sku
					c['quiebre']=pedido.quebrado
					b<<c
					if pedido.quebrado
						a['color']="red"
					else
						parcial = true
					end

					if pedido.cantidad > pedido.cant_vendida
						a['color']="yellow"

					end

				end
				a['pedido']=b
				@paquetesPedidos<<a
			end
		end
		@paquetesPedidos
	end
end
