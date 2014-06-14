class Venta < ActiveRecord::Base
  belongs_to :spree_variant, :class_name => "Spree::Variant"
  belongs_to :pedido, :class_name => "Pedido"
  def self.generarReportes
    Venta.where(created_at: (Time.now.midnight - 1.day)..Time.now.midnight).each do |venta|
      Ventacliente.agregar(venta.utilidad, venta.ingreso, venta.pedido.cantidad,venta.pedido.sku,venta.fecha)
      Ventaproducto.agregar(venta.utilidad, venta.ingreso, venta.pedido.cantidad, venta.pedido.rut, venta.fecha)
    end
  end
end

