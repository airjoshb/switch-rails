class OrderableResource < Avo::BaseResource
  self.title = :id
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :current, as: :boolean
  field :subscription_id, as: :text
  field :delivery_method, as: :select, enum: { 'Pickup' => 'pickup', 'Delivery' => 'delivery', 'Shipping' => 'shipping' }
  field :notes, as: :text
  field :quantity, as: :number
  field :variation, as: :belongs_to
  field :cart, as: :belongs_to
  field :customer_order , as: :belongs_to
  # add fields here
end
