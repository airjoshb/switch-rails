class CustomerBoxResource < Avo::BaseResource
  self.title = :date
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end
  self.model_class = ::CustomerBox
  
  action ExportCsv

  field :id, as: :id
  # Fields generated from the model
  field :box, as: :belongs_to
  field :customer_orders, as: :has_and_belongs_to_many
  field :customer_name, as: :text do |order|
    order.customer.name
  end
  field :customer_order_address, as: :text do |customer_order|
    customer_order.address
  end
  field :note, as: :trix
  field :variations, as: :text do |customer_box|
    customer_box.customer_orders.flat_map(&:variations).map(&:name).join(", ")
  end
  field :orderable_notes, as: :text do |orderable|
    orderable.orderable_notes
  end
  field :order_preferences, as: :text do |customer_order|
    customer_order.order_preferences
  end
  field :email_sent, as: :boolean
  field :email_sent_date, as: :date_time
  # add fields here
end
