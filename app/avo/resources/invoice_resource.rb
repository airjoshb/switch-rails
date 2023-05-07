class InvoiceResource < Avo::BaseResource
  self.title = :id
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :customer_order, as: :belongs_to
  field :amount_due, as: :number
  field :amount_paid, as: :number
  field :attempted, as: :boolean
  field :invoice_status, as: :select, enum: Invoice.invoice_statuses, sortable: true
  field :subscription_id, as: :text
  field :invoice_id, as: :text
  field :paid, as: :boolean
  field :period_end, as: :date_time
  field :period_start, as: :date_time
  field :fulfilled, as: :boolean
  field :fulfilled_date, as: :date_time
  # add fields here
end
