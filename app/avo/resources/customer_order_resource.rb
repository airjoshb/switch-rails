class CustomerOrderResource < Avo::BaseResource
  self.title = :guid
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  action MarkComplete
  
  field :id, as: :id
  # Fields generated from the model
  field :guid, as: :text
  field :order_status, as: :select, enum: CustomerOrder.order_statuses
  field :stripe_id, as: :text, hide_on: [:index]
  field :subscription_id, as: :text, hide_on: [:index]
  field :amount, as: :number
  field :fulfillment_method, as: :text
  field :payment_method, as: :has_one
  field :address, as: :has_one
  field :customer, as: :has_one
  field :orderables, as: :has_many
  field :invoices, as: :has_many
  field :description, as: :textarea
  field :completed_at, as: :date_time
  field :receipt_sent, as: :boolean
  field :receipt_sent_date, as: :date_time
  # add fields here
end
