require "test_helper"

class CustomerTest < ActiveSupport::TestCase
  self.fixture_table_names = []

  test "destroy removes customer-owned joins but not shared email records" do
    customer = Customer.create!(name: "Delete Me", email: "delete-me@example.com")
    customer_order = CustomerOrder.create!(customer: customer)
    email = Email.create!(subject: "Campaign")
    customer_email = CustomerEmail.create!(customer: customer, email: email)

    assert_difference("Customer.count", -1) do
      assert_difference("CustomerOrder.count", -1) do
        assert_difference("CustomerEmail.count", -1) do
          assert_no_difference("Email.count") do
            customer.destroy
          end
        end
      end
    end

    assert_not CustomerOrder.exists?(customer_order.id)
    assert_not CustomerEmail.exists?(customer_email.id)
    assert Email.exists?(email.id)
  end
end
