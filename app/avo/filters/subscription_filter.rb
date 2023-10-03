class SubscriptionFilter < Avo::Filters::SelectFilter
  self.name = "Subscription filter"
  # self.visible = -> do
  #   true
  # end

  def apply(request, query, value)
    case value
    when 'active'
      query.where(subscription_status: 'active').processed
    when 'canceled'
      query.where(subscription_status: 'canceled').processed
    when 'paused'
      query.where(subscription_status: 'paused').processed
    else
      query
    end
  end

  def options
    {
      'active': 'Active',
      'canceled': 'Canceled',
      'paused': 'Paused',
    }
  end

end
