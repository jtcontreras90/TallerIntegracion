class EOrder < ActiveRecord::Base

	def readOrders
		orders=Spree::Order.where('state=? AND payment_state != ?', "complete", "paid")
		orders.each do |o|
			address="#{o.ship_address.address1}, #{o.ship_address.address2}, #{o.ship_address.city}"
			pedidoID=o.number
			o.line_items.each do |li|
				eo=EOrder.new
				eo.sku=li.variant.sku
				eo.cantidad=li.quantity
				eo.direccion= address
				eo.precio=li.pre_tax_amount.to_i
				eo.pedidoID="ecommerce:#{pedidoID}"
				eo.enviado=false
				eo.oder_id=o.id
				eo.save
			end
			o.payment_state="paid"
			o.shipment_state="ready"
			o.approver_id=1
			o.approved_at=DateTime.now
			o.save
			p=o.payments.first
			p.state="completed"
			p.amount=p.uncaptured_amount
			p.uncaptured_amount=0
			p.save
		end
	end


	def sendOrders
		ecommerceOrders=EOrder.where(enviado: false)

		ecommerceOrders.each do |eo|
			ApiBodega.despacharProducto(eo.sku, eo.cantidad, eo.direccion, eo.precio, eo.pedidoID)

			eo.enviado=true
			eo.save

			o=Spree::Order.where(id: eo.order_id).first
			o.shipment_state="shipped"
			o.save
		end
	end
end