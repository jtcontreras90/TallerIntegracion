class EOrder < ActiveRecord::Base

	def readOrders
    	Rails.logger.info "[SCHEDULE][EORDER.READORDERS]Begin at #{Time.now}"
		orders=Spree::Order.where('state=? AND payment_state != ?', "complete", "paid")
		orders.each do |o|
			puts "Processing #{o.id}: #{o.number}"
			address="#{o.ship_address.address1}, #{o.ship_address.address2}, #{o.ship_address.city}"
			pedidoID=o.number
			o.line_items.each do |li|
				puts "Processing #{o.id}: #{o.number}: Cantidad #{li.quantity} (#{li.pre_tax_amount})"
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
			puts "Processed #{o.id}: #{o.number}"
		end
    	Rails.logger.info "[SCHEDULE][EORDER.READORDERS]Finish at #{Time.now}"
	end


	def sendOrders
    	Rails.logger.info "[SCHEDULE][EORDER.SENDORDERS]Begin at #{Time.now}"

		ecommerceOrders=EOrder.where(enviado: false)

		ecommerceOrders.each do |eo|
			puts "Tratando de enviar #{eo.pedidoID}"
			ApiBodega.despacharProducto(eo.sku, eo.cantidad, eo.direccion, eo.precio, eo.pedidoID)
			puts "Enviado #{eo.pedidoID}"

			eo.enviado=true
			eo.save

			o=Spree::Order.where(id: eo.order_id).first
			o.shipment_state="shipped"
			o.save
		end
    	Rails.logger.info "[SCHEDULE][EORDER.SENDORDERS]Begin at #{Time.now}"
	end
end