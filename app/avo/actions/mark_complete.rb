class MarkComplete < Avo::BaseAction
  self.name = "Mark complete"
  # self.visible = -> do
  #   true
  # end

  self.message = "Are you sure you want to mark the order(s) as complete?"
  self.confirm_button_label = "Mark Completed"
  self.cancel_button_label = "Not Yet"

  def handle(**args)
    models = args[:models]

    models.each do |model|
      model.update(completed_at: Time.current)
      model.fulfilled!
    end
    succeed "Order(s) marked as complete!"
    reload
  end
end
