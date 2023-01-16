class PaymentMethodResource < Avo::BaseResource
  self.title = :id
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :stripe_id, as: :text
  field :last_4, as: :text
  field :customer_order, as: :belongs_to
  field :cvc_check, as: :boolean
  field :card_type, as: :text
  # add fields here
end
