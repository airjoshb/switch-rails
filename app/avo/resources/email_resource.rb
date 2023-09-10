class EmailResource < Avo::BaseResource
  self.title = :id
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :date_sent, as: :date_time
  field :subject, as: :text
  field :customer, as: :belongs_to
  # add fields here
end
