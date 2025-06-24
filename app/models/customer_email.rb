class CustomerEmail < ApplicationRecord
  belongs_to :email
  belongs_to :customer
end
