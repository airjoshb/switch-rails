class BoxResource < Avo::BaseResource
  self.title = :id
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :date, as: :date_time
  field :note, as: :trix, attachment_key: :trix_attachments, through: :action_text_rich_texts
  field :variations, as: :has_many
  # add fields here
end
