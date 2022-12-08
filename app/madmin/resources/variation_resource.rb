class VariationResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :name
  attribute :image
  attribute :amount
  attribute :active
  attribute :add_on
  attribute :count_on_hand
  attribute :unit_quantity
  attribute :row_order
  attribute :recurring
  attribute :created_at, form: false
  attribute :updated_at, form: false
  attribute :inventory_type
  attribute :stripe_id
  attribute :interval
  attribute :interval_count, form: false
  attribute :image

  # Associations
  attribute :product
  attribute :orderables
  attribute :carts

  # Uncomment this to customize the display name of records in the admin area.
  # def self.display_name(record)
  #   record.name
  # end

  # Uncomment this to customize the default sort column and direction.
  # def self.default_sort_column
  #   "created_at"
  # end
  #
  # def self.default_sort_direction
  #   "desc"
  # end
end
