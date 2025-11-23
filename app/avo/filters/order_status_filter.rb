class OrderStatusFilter < Avo::Filters::SelectFilter
  self.name = "Order Status"
  # self.visible = -> do
  #   true
  # end

  def apply(request, query, value)
    case value
    when 'processed'
      query.processed
    when 'fulfilled'
      query.fulfilled
    else
      query
    end
  end

  def options
    {
      'processed': 'Processed',
      'fulfilled': 'Fulfilled',
    }
  end

end
