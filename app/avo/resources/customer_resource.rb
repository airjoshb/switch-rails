class CustomerResource < Avo::BaseResource
  self.title = :email
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :name, as: :text
  field :email, as: :text
  field :phone, as: :text
  field :stripe_id, as: :text
  field :customer_orders, as: :has_many
  field :addresses, as: :has_many, through: :orders
  field :payment_methods, as: :has_many, through: :orders
  # add fields here
end
