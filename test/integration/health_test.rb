require "test_helper"

class HealthTest < ActionDispatch::IntegrationTest
  test "reports healthy without authentication when database is available" do
    get health_path

    assert_response :success
    assert_equal "ok", response.body
  end
end
