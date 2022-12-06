require "test_helper"

class ChargesControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get charges_create_url
    assert_response :success
  end
end
