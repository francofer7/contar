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
          phone_country: "AR",
          phone: "351 555 9999",
          password: "password123",
          password_confirmation: "password123",
          role: "operator",
          active: "1",
          converter_ids: [ converters(:cards).id ]
        }
      }
    end

    created = User.find_by!(email: "olivia@example.com")
    assert_equal "AR", created.phone_country
    assert_equal "+5493515559999", created.phone
    assert_equal [ converters(:cards) ], created.assigned_converters.to_a
    assert_redirected_to admin_users_path

    follow_redirect!
    assert_select "a[href^='https://wa.me/5493515559999?text=']", text: "Enviar acceso por WhatsApp"
    assert_includes response.body, "password123"
  end

  test "admin cannot remove own admin access" do
    patch admin_user_path(users(:admin)), params: {
      user: { name: users(:admin).name, email: users(:admin).email, role: "operator", active: "1", converter_ids: [] }
    }

    assert_response :unprocessable_entity
    assert users(:admin).reload.admin?
  end

  test "edit form shows the local number without duplicating the country prefix" do
    get edit_admin_user_path(users(:operator))

    assert_response :success
    assert_select "select.phone-country-select[name='user[phone_country]'] option[value='AR'][selected]", text: /🇦🇷 AR \+54/
    assert_select "input[name='user[phone]'][value='3515550002']"
  end

  test "operator cannot manage users" do
    delete logout_path
    post login_path, params: { email: users(:operator).email, password: "password123" }

    get admin_users_path
    assert_redirected_to root_path
  end
end
