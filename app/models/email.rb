class Email < ApplicationRecord
  belongs_to :box
  has_rich_text :body

  def generate_customer_emails
    'get all subscribers with boxes
    create emails using customer emails with variation prefs, notes, and add ons'
  end
end
