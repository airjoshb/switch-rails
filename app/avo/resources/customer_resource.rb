class CustomerResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.search_query = -> do
    scope.ransack(name_eq: params[:q],stripe_id_eq: params[:q],email_eq: params[:q], m: "or").result(distinct: false)
  end

  field :id, as: :id
  # Fields generated from the model
  field :name, as: :text
  field :email, as: :text
  field :phone, as: :text
  field :promotion_consent, as: :boolean, sortable: true
  field :fan, as: :boolean, sortable: true
  field :preferences, as: :has_many
  field :stripe_id, as: :text
  field :customer_orders, as: :has_many
  field :customer_boxes, as: :has_many, through: :customer_orders
  field :invoices, as: :has_many, through: :customer_orders
  field :addresses, as: :has_many, through: :customer_orders
  field :payment_methods, as: :has_many, through: :customer_orders
  # add fields here
end
