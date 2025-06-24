class CustomerEmailResource < Avo::BaseResource
  self.title = :id
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :email_id, as: :number
  field :customer_id, as: :number
  field :email_sent, as: :boolean
  field :sent_date, as: :date_time
  field :email, as: :belongs_to
  field :customer, as: :belongs_to
  # add fields here
end
