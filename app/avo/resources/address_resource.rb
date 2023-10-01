class AddressResource < Avo::BaseResource
  self.title = :street_1
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :street_1, as: :text
  field :street_2, as: :text
  field :city, as: :text
  field :state, as: :text
  field :postal, as: :text
  field :address_check, as: :boolean
  field :customer_order, as: :belongs_to
  # add fields here
end
