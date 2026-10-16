require "test_helper"

class AccessControlTest < ActionDispatch::IntegrationTest
  test "authentication is required" do
    get root_path

    assert_redirected_to login_path
  end

  test "operator sees and opens only assigned converter" do
    sign_in(users(:operator))

    get root_path
    assert_response :success
    assert_select "h2", text: "Extractos bancarios"
    assert_select "h2", text: "Tarjetas de crédito", count: 0

    get converter_path(converters(:banking).key)
    assert_response :success
    assert_includes response.body, "Extractor de Movimientos Bancarios"

    get converter_path(converters(:cards).key)
    assert_redirected_to root_path
  end

  test "converter dependencies also require authentication" do
    get converter_asset_path(filename: "pdf.min.js")
    assert_redirected_to login_path

    sign_in(users(:operator))
    get converter_asset_path(filename: "pdf.min.js"), headers: { "HTTP_REFERER" => converter_url(converters(:banking).key) }
    assert_response :success
    assert_equal "application/javascript", response.media_type
  end

  test "admin sees every converter and user management" do
    sign_in(users(:admin))

    get root_path
    assert_response :success
    assert_select "h2", text: "Extractos bancarios"
    assert_select "h2", text: "Tarjetas de crédito"

    get admin_users_path
    assert_response :success
  end

  test "inactive user cannot sign in" do
    post login_path, params: { email: users(:inactive).email, password: "password123" }

    assert_response :unprocessable_entity
    assert_select ".flash.alert", text: /no son correctos/
  end

  private

  def sign_in(user)
    post login_path, params: { email: user.email, password: "password123" }
    assert_redirected_to root_path
  end
end
