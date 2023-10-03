class IntervalFilter < Avo::Filters::SelectFilter
  self.name = "Interval filter"
  # self.visible = -> do
  #   true
  # end

  def apply(request, query, value)
    case value
    when 'weekly'
      query.weekly.current_sub
    when 'bimonthly'
      query.bimonthly.current_sub
    when 'monthly'
      query.monthly.current_sub
    else
      query
    end
  end

  def options
    {
      'weekly': 'Weekly',
      'bimonthly': 'Bimonthly',
      'monthly': 'Monthly',
    }
  end
end
