class CustomerOrderResource < Avo::BaseResource
  self.title = :guid
  self.includes = []
  self.search_query = -> do
    scope.ransack(id_eq: params[:q], m: "or").result(distinct: false).merge(scope.recent)
  end

  self.resolve_query_scope = ->(model_class:) do
    model_class.recent
  end

  action MarkComplete
  action FetchInvoices
  action ExportPdf

  filter SubscriptionFilter
  filter IntervalFilter
  
  field :id, as: :id
  field :created_at, as: :date_time, sortable: true
  # Fields generated from the model
  field :guid, as: :text
  field :order_status, as: :select, enum: CustomerOrder.order_statuses
  field :subscription_status, as: :select, options: CustomerOrder::SUBSCRIPTION_STATUS, include_blank: 'No Subscription'
  field :stripe_checkout_id, as: :text, hide_on: [:index]
  field :subscription_id, as: :text, hide_on: [:index]
  field :last_box_date, as: :date_time
  field :amount, as: :number
  field :fulfillment_method, as: :text
  field :payment_method, as: :has_one, hide_on: [:index]
  field :address, as: :has_one, hide_on: [:index]
  field :customer, as: :belongs_to, sortable: true
  field :preferences, as: :has_many
  field :orderables, as: :has_many
  field :invoices, as: :has_many
  field :description, as: :textarea
  field :completed_at, as: :date_time, hide_on: [:index]
  field :receipt_sent, as: :boolean
  field :receipt_sent_date, as: :date_time
  field :customer_boxes, as: :has_and_belongs_to_many, hide_on: [:index]
  # add fields here
end
