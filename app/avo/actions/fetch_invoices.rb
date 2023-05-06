class FetchInvoices < Avo::BaseAction
  self.name = "Fetch Invoices"
  # self.visible = -> do
  #   true
  # end

  self.message = "Are you sure you want to fetch invoices?"
  self.confirm_button_label = "Fetch Invoices"
  self.cancel_button_label = "Not Yet"

  def handle(**args)
    models = args[:models]

    models.each do |model|
      model.fetch_invoices
    end
    succeed "Invoices fetched!"
    reload
  end
end
