class ArtifactResource < Avo::BaseResource
  self.title = :name
  self.model_class = 'Artifact'
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  self.find_record_method = ->(model_class:, id:, params:) {
    model_class.friendly.find id
  }

  field :id, as: :id
  # Fields generated from the model
  field :name, as: :text
  field :url, as: :text
  field :image, as: :file
  field :posts, as: :has_and_belongs_to_many
  field :products, as: :has_and_belongs_to_many
  field :category, as: :belongs_to
  field :embed, as: :text
  field :description, as: :trix, attachment_key: :trix_attachments, through: :action_text_rich_texts, hide_on: [:new]
  # add fields here
end
