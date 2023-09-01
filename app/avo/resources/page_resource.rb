class PageResource < Avo::BaseResource
  self.title = :title
  self.includes = []
  self.resolve_query_scope = ->(model_class:) do
    model_class.order(title: :asc)
  end

  self.find_record_method = ->(model_class:, id:, params:) {
    model_class.friendly.find id
  }
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :title, as: :text
  field :description, as: :textarea
  field :nav, as: :boolean
  field :content, as: :trix, attachment_key: :trix_attachments, through: :action_text_rich_texts
  # add fields here

end
