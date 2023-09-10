class VariationResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  self.find_record_method = ->(model_class:, id:, params:) {
    model_class.friendly.find id
  }
  self.resolve_query_scope = ->(model_class:) do
    model_class.order(name: :asc)
  end

  field :id, as: :id
  # Fields generated from the model
  field :product, as: :belongs_to
  field :name, as: :text
  field :amount, as: :number
  field :active, as: :boolean
  field :add_on, as: :boolean
  field :preferences, as: :has_many
  field :count_on_hand, as: :number
  field :unit_quantity, as: :number
  field :row_order, as: :number
  field :recurring, as: :boolean
  field :inventory_type, as: :select, enum: ::Variation.inventory_types
  field :interval, as: :select, enum: ::Variation.intervals, include_blank: 'No Interval'
  field :interval_count, as: :number
  field :orderables, as: :has_many
  field :stripe_id, as: :text, hide_on: [:index, :new]
  field :carts, as: :has_many, through: :orderables
  # add fields here

end
