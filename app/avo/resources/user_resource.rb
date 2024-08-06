class UserResource < Avo::BaseResource
  self.title = :email
  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  # Fields generated from the model
  field :email, as: :text
  field :mode, as: :select, enum: ::User.modes, placeholder: 'Choose the mode.', include_blank: 'No mode'
  field :notice, as: :text
  field :password_digest, as: :text
  field :verified, as: :boolean
  field :email_verification_tokens, as: :has_many
  field :password_reset_tokens, as: :has_many
  field :sessions, as: :has_many
  # add fields here
end
