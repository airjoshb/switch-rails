class OrderableResource < Avo::BaseResource
  self.title = :id
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :variation_id, as: :number
  field :cart_id, as: :number
  field :quantity, as: :number
  field :variation, as: :belongs_to
  field :cart, as: :belongs_to
  field :customer_order , as: :belongs_to
  # add fields here
end
