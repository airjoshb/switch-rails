class EmailResource < Avo::BaseResource
  self.title = :subject
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :date_sent, as: :date_time
  field :subject, as: :text
  field :campaigns, as: :has_and_belongs_to_many
  field :customer_emails, as: :has_many
  field :customers, as: :has_many, through: :customer_emails
  field :body, as: :trix, attachment_key: :trix_attachments, through: :action_text_rich_texts

  # add fields here
end
