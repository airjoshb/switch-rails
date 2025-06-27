class PreferenceResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end
  self.find_record_method = ->(model_class:, id:, params:) {
    model_class.friendly.find id
  }
  self.resolve_query_scope = ->(model_class:) do
    model_class.order(name: :asc)
  end

  field :id, as: :id
  # Fields generated from the model
  field :name, as: :text
  field :options, as: :text
  # add fields here
end
