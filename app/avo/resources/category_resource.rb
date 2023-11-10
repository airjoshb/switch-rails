class CategoryResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.resolve_query_scope = ->(model_class:) do
    model_class.order(row_order: :asc)
  end

  self.find_record_method = ->(model_class:, id:, params:) {
    model_class.friendly.find id
  }
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :name, as: :text
  field :image, as: :file
  field :description, as: :textarea
  field :row_order, as: :number
  field :products, as: :has_many
  # add fields here

end
