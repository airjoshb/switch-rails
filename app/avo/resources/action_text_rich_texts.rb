class ActionTextRichTexts < Avo::BaseResource
  self.title = :id
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end
  self.model_class=ActionText::RichText

  field :id, as: :id
  # Fields generated from the model
  field :name, as: :text
  field :body, as: :textarea
  field :record_type, as: :select, options: {'Product': :product, 'Page': :page}, display_with_value: true
  field :pages, as: :belongs_to, polymorphic_as: :record
  field :products, as: :belongs_to, polymorphic_as: :record
  # add fields here
end
