require "test_helper"

class Web::NoticeControllerTest < ActionDispatch::IntegrationTest
  test "error page is reachable" do
    get error_notice_path
    assert_response :success
  end

  test "not found page returns 404" do
    get error_not_found_path
    assert_response :not_found
  end
end
