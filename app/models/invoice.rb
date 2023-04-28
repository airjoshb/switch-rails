class Invoice < ApplicationRecord
  belongs_to :customer_order, optional: true
  enum invoice_status: { open: 'open', paid: 'paid', void: 'void', uncollectible: 'uncollectible' }

  def pay_invoice
    invoice = Stripe::Invoice.retrieve(invoice_id)
    self.update(amount_paid: invoice.amount_paid, paid: true)
    self.paid!
  end

end
