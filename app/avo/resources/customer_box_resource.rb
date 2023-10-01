class CustomerBoxResource < Avo::BaseResource
  self.title = :date
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end
  self.model_class = ::CustomerBox
  field :id, as: :id
  # Fields generated from the model
  field :date, as: :date_time
  field :box, as: :belongs_to
  field :customer, as: :has_one
  field :address, as: :has_one
  field :customer_order, as: :belongs_to
  field :note, as: :trix
  # add fields here
end
