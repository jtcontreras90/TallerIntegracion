class Venta < ActiveRecord::Base
  belongs_to :spree_variant, :class_name => "Spree::Variant"
  belongs_to :pedido, :class_name => "Pedido"
  def generarReportes
    Ventas.where(created_at: (Time.now.midnight - 1.day)..Time.now.midnight).each do |venta|
      Ventacliente.agregar(:utilidades=> (0*venta.cantidad), :ingresos=>(0*venta.cantidad), :cantidad_transada=>venta.cantidad,:sku_producto=>venta.sku,:fecha=>venta.fecha)
    end
  end
end

