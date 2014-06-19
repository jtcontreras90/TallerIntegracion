class FixNumericTypesForSpree < ActiveRecord::Migration
	def self.up
		change_column :spree_adjustments, :amount, :decimal, :precision => 14, :scale => 2

		change_column :spree_line_items, :price, :decimal, :precision => 14, :scale => 2, null: false
		change_column :spree_line_items, :cost_price, :decimal, :precision => 14, :scale => 2
		change_column :spree_line_items, :adjustment_total, :decimal, :precision => 14, :scale => 2, default: 0.0
		change_column :spree_line_items, :additional_tax_total, :decimal, :precision => 14, :scale => 2, default: 0.0
		change_column :spree_line_items, :promo_total, :decimal, :precision => 14, :scale => 2, default: 0.0
		change_column :spree_line_items, :included_tax_total, :decimal, :precision => 14, :scale => 2, default: 0.0, null: false
		change_column :spree_line_items, :pre_tax_amount, :decimal, :precision => 14, :scale => 2

		change_column :spree_orders, :item_total, :decimal, :precision => 14, :scale => 2, default: 0.0, null: false
		change_column :spree_orders, :total, :decimal, :precision => 14, :scale => 2, default: 0.0, null: false
		change_column :spree_orders, :adjustment_total, :decimal, :precision => 14, :scale => 2, default: 0.0, null: false
		change_column :spree_orders, :payment_total, :decimal, :precision => 14, :scale => 2, default: 0.0
		change_column :spree_orders, :shipment_total, :decimal, :precision => 14, :scale => 2, default: 0.0, null: false
		change_column :spree_orders, :additional_tax_total, :decimal, :precision => 14, :scale => 2, default: 0.0
		change_column :spree_orders, :promo_total, :decimal, :precision => 14, :scale => 2, default: 0.0
		change_column :spree_orders, :included_tax_total, :decimal, :precision => 14, :scale => 2, default: 0.0, null: false
	
		change_column :spree_payment_capture_events, :amount, :decimal, :precision => 14, :scale => 2, default: 0.0

		change_column :spree_payments, :amount, :decimal, :precision => 14, :scale => 2, default: 0.0, null: false
		change_column :spree_payments, :uncaptured_amount, :decimal, :precision => 14, :scale => 2, default: 0.0

		change_column :spree_return_authorizations, :amount, :decimal, :precision => 14, :scale => 2, default: 0.0

		change_column :spree_shipments, :cost, :decimal, :precision => 14, :scale => 2
		change_column :spree_shipments, :adjustment_total, :decimal, :precision => 14, :scale => 2, default: 0.0
		change_column :spree_shipments, :additional_tax_total, :decimal, :precision => 14, :scale => 2, default: 0.0
		change_column :spree_shipments, :promo_total, :decimal, :precision => 14, :scale => 2, default: 0.0
		change_column :spree_shipments, :included_tax_total, :decimal, :precision => 14, :scale => 2, default: 0.0, null: false
		change_column :spree_shipments, :pre_tax_amount, :decimal, :precision => 14, :scale => 2

		change_column :spree_shipping_rates, :cost, :decimal, :precision => 14, :scale => 2, default: 0.0

		change_column :spree_variants, :weight, :decimal, :precision => 14, :scale => 2, default: 0.0
		change_column :spree_variants, :height, :decimal, :precision => 14, :scale => 2
		change_column :spree_variants, :width, :decimal, :precision => 14, :scale => 2
		change_column :spree_variants, :depth, :decimal, :precision => 14, :scale => 2

	end

	def self.down
		change_column :spree_adjustments, :amount, :decimal, :precision => 10, :scale => 2

		change_column :spree_line_items, :price, :decimal, :precision => 8, :scale => 2, null: false
		change_column :spree_line_items, :cost_price, :decimal, :precision => 8, :scale => 2
		change_column :spree_line_items, :adjustment_total, :decimal, :precision => 10, :scale => 2, default: 0.0
		change_column :spree_line_items, :additional_tax_total, :decimal, :precision => 10, :scale => 2, default: 0.0
		change_column :spree_line_items, :promo_total, :decimal, :precision => 10, :scale => 2, default: 0.0
		change_column :spree_line_items, :included_tax_total, :decimal, :precision => 10, :scale => 2, default: 0.0, null: false
		change_column :spree_line_items, :pre_tax_amount, :decimal, :precision => 8, :scale => 2

		change_column :spree_orders, :item_total, :decimal, :precision => 10, :scale => 2, default: 0.0, null: false
		change_column :spree_orders, :total, :decimal, :precision => 10, :scale => 2, default: 0.0, null: false
		change_column :spree_orders, :adjustment_total, :decimal, :precision => 10, :scale => 2, default: 0.0, null: false
		change_column :spree_orders, :payment_total, :decimal, :precision => 10, :scale => 2, default: 0.0
		change_column :spree_orders, :shipment_total, :decimal, :precision => 10, :scale => 2, default: 0.0, null: false
		change_column :spree_orders, :additional_tax_total, :decimal, :precision => 10, :scale => 2, default: 0.0
		change_column :spree_orders, :promo_total, :decimal, :precision => 10, :scale => 2, default: 0.0
		change_column :spree_orders, :included_tax_total, :decimal, :precision => 10, :scale => 2, default: 0.0, null: false

		change_column :spree_payment_capture_events, :amount, :decimal, :precision => 10, :scale => 2, default: 0.0

		change_column :spree_payment_methods, :amount, :decimal, :precision => 10, :scale => 2, default: 0.0, null: false
		change_column :spree_payment_methods, :uncaptured_amount, :decimal, :precision => 10, :scale => 2, default: 0.0

		change_column :spree_return_authorizations, :amount, :decimal, :precision => 10, :scale => 2, default: 0.0, null: false

		change_column :spree_shipments, :cost, :decimal, :precision => 8, :scale => 2
		change_column :spree_shipments, :adjustment_total, :decimal, :precision => 10, :scale => 2, default: 0.0
		change_column :spree_shipments, :additional_tax_total, :decimal, :precision => 10, :scale => 2, default: 0.0
		change_column :spree_shipments, :promo_total, :decimal, :precision => 10, :scale => 2, default: 0.0
		change_column :spree_shipments, :included_tax_total, :decimal, :precision => 10, :scale => 2, default: 0.0, null: false
		change_column :spree_shipments, :pre_tax_amount, :decimal, :precision => 8, :scale => 2

		change_column :spree_shipping_rates, :cost, :decimal, :precision => 8, :scale => 2, default: 0.0

		change_column :spree_variants, :weight, :decimal, :precision => 8, :scale => 2, default: 0.0
		change_column :spree_variants, :height, :decimal, :precision => 8, :scale => 2
		change_column :spree_variants, :width, :decimal, :precision => 8, :scale => 2
		change_column :spree_variants, :depth, :decimal, :precision => 8, :scale => 2


	end
end
