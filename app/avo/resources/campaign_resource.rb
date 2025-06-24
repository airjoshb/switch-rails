class CampaignResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end
  action SendCampaignEmail

  field :id, as: :id
  # Fields generated from the model
  field :name, as: :text
  field :description, as: :textarea
  field :emails, as: :has_and_belongs_to_many
  field :customers, as: :has_and_belongs_to_many
  # add fields here
end
