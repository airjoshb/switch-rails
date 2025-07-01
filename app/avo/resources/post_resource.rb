class PostResource < Avo::BaseResource
  self.title = :title
  self.model_class = 'Post'
  self.includes = []
  self.resolve_query_scope = ->(model_class:) do
    model_class.order(created_at: :asc)
  end

  self.find_record_method = ->(model_class:, id:, params:) {
    model_class.friendly.find id
  }
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  field :created_at, as: :date_time, hide_on: [:new]
  # Fields generated from the model
  field :title, as: :text
  field :image, as: :file
  field :category, as: :belongs_to
  field :content, as: :trix, attachment_key: :trix_attachments, through: :action_text_rich_texts
  field :artifacts, as: :has_and_belongs_to_many
  # add fields here
end
