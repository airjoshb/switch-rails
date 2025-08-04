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
  field :date, as: :date_time
  field :box, as: :belongs_to
  field :customer, as: :has_one
  field :address, as: :has_one
  field :customer_order, as: :belongs_to
  field :orderable_notes, as: :text
  field :order_preferences, as: :text
  field :note, as: :trix
  field :email_sent, as: :boolean
  field :email_sent_date, as: :date_time
  # add fields here
end
