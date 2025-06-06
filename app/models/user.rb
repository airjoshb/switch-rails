class User < ApplicationRecord
  has_secure_password

  has_many :email_verification_tokens, dependent: :destroy
  has_many :password_reset_tokens, dependent: :destroy

  has_many :sessions, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, allow_nil: true, length: { minimum: 8 }
  # validates :password, not_pwned: { message: "might easily be guessed" }
  # attribute :mode, :string
  enum :mode, [:full, :subscribe_only, :vacation] , default: :full

  before_validation do
    self.email = email.try(:downcase).try(:strip)
  end

  before_validation if: :email_changed? do
    self.verified = false
  end

  after_update if: :password_digest_previously_changed? do
    sessions.where.not(id: Current.session).destroy_all
  end

end
