class Email < ApplicationRecord
  has_many :customer_emails, as: :emailable

end
