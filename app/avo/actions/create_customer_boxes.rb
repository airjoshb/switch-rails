class CreateCustomerBoxes < Avo::BaseAction
  self.name = "Create customer boxes"
  # self.visible = -> do
  #   true
  # end
  self.message = "Are you sure you want to create customer boxes?"
  self.confirm_button_label = "Customer Boxes"
  self.cancel_button_label = "Not Yet"

  def handle(**args)
    models, fields, current_user, resource = args.values_at(:models, :fields, :current_user, :resource)

    models.each do |model|
      model.generate_customer_boxes
    end
    succeed "Boxes Created!"
    reload
  end
end
