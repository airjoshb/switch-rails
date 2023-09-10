class CustomerEmail < Email
  belongs_to :emailable
  belongs_to :customer
end
