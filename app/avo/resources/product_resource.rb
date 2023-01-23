class ProductResource < Avo::BaseResource
  self.title = :name
  self.model_class = 'Product'
  self.includes = []
  self.resolve_query_scope = ->(model_class:) do
    model_class.order(name: :asc)
  end

  self.resolve_find_scope = ->(model_class:) do
    model_class.friendly
  end

  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :name, as: :text
  field :description, as: :textarea
  field :content, as: :trix, attachment_key: :trix_attachments, through: :action_text_rich_texts
  field :image, as: :file
  field :row_order, as: :number
  field :active, as: :boolean
  field :variations, as: :has_many
  field :category, as: :belongs_to
  field :stripe_id, as: :text, hide_on: [:edit, :index, :new]

  # add fields here

  
end
