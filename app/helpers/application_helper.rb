module ApplicationHelper
  def formatted_price(amount)
    sprintf("$%0.2f", amount / 100.0)
  end

  def display_price(amount)
    sprintf("$%0.0f", amount / 100.0)
  end
 
end
