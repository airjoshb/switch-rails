class PageResource < Avo::BaseResource
  self.title = :title
  self.includes = []
  self.resolve_query_scope = ->(model_class:) do
    model_class.order(title: :asc)
  end

  self.resolve_find_scope = ->(model_class:) do
    model_class.friendly
  end
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :title, as: :text
  field :description, as: :textarea
  field :nav, as: :boolean
  # add fields here

end
