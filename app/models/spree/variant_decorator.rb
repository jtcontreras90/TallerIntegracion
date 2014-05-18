Spree::Variant.class_eval do
  has_many :ventas, :class_name => 'Venta', :foreign_key => 'spree_variant_id'
end