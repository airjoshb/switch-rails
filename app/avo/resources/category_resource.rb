class CategoryResource < Avo::BaseResource
  self.title = :name
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
  field :image, as: :file
  field :products, as: :has_many
  # add fields here

end
