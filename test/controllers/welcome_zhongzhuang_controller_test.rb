require "test_helper"

class WelcomeZhongzhuangControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get welcome_zhongzhuang_index_url
    assert_response :success
  end
end
