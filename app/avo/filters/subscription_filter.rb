class SubscriptionFilter < Avo::Filters::SelectFilter
  self.name = "Subscription filter"
  # self.visible = -> do
  #   true
  # end

  def apply(request, query, value)
    case value
    when 'active'
      query.where(subscription_status: 'active')
    when 'canceled'
      query.where(subscription_status: 'canceled')
    when 'paused'
      query.where(subscription_status: 'paused')
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
