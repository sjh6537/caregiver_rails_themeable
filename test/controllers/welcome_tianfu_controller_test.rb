require "test_helper"

class WelcomeTianfuControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get welcome_tianfu_index_url
    assert_response :success
  end
end
