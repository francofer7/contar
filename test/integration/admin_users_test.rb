require "test_helper"

class AdminUsersTest < ActionDispatch::IntegrationTest
  setup do
    post login_path, params: { email: users(:admin).email, password: "password123" }
  end

  test "admin creates operator with assigned converter" do
    assert_difference -> { User.count }, 1 do
      post admin_users_path, params: {
        user: {
          name: "Olivia Nueva",
          email: "olivia@example.com",
          password: "password123",
          password_confirmation: "password123",
          role: "operator",
          active: "1",
          converter_ids: [converters(:cards).id]
        }
      }
    end

    created = User.find_by!(email: "olivia@example.com")
    assert_equal [converters(:cards)], created.assigned_converters.to_a
    assert_redirected_to admin_users_path
  end

  test "admin cannot remove own admin access" do
    patch admin_user_path(users(:admin)), params: {
      user: { name: users(:admin).name, email: users(:admin).email, role: "operator", active: "1", converter_ids: [] }
    }

    assert_response :unprocessable_entity
    assert users(:admin).reload.admin?
  end

  test "operator cannot manage users" do
    delete logout_path
    post login_path, params: { email: users(:operator).email, password: "password123" }

    get admin_users_path
    assert_redirected_to root_path
  end
end
