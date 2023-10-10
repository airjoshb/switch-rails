class SendBoxEmail < Avo::BaseAction
  self.name = "Send box email"
  # self.visible = -> do
  #   true
  # end
  self.visible = -> { view == :show }

  self.message = "Are you sure you want to email subscribers?"
  self.confirm_button_label = "Email Subscribers"
  self.cancel_button_label = "Not Yet"

  def handle(**args)
    models = args[:models]

    models.each do |model|
      model.send_email
    end
    succeed "Emails Sent!"
    reload
  end
end
