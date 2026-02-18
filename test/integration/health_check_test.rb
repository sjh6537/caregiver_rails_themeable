require "test_helper"

class HealthCheckTest < ActionDispatch::IntegrationTest
  test "up endpoint returns success" do
    host! "www.example.com"
    get "/up"
    assert_response :success
  end
end
