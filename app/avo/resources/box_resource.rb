class BoxResource < Avo::BaseResource
  self.title = :date
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end
  self.link_to_child_resource = true

  action CreateCustomerBoxes

  field :id, as: :id
  # Fields generated from the model
  field :date, as: :date_time
  field :type, as: :select, name: "Type", options: { CustomerBox: "CustomerBox" }, include_blank: true
  field :note, as: :trix, attachment_key: :trix_attachments, through: :action_text_rich_texts
  field :variations, as: :has_many
  field :customer_boxes, as: :has_many, hide_search_input: true
  
  # add fields here
end
