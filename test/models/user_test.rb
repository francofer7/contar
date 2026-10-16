require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "normalizes email" do
    user = User.new(name: "Nueva", email: "  NUEVA@EXAMPLE.COM ", password: "password123")

    assert user.valid?
    assert_equal "nueva@example.com", user.email
  end

  test "operator only receives assigned active converters" do
    assert_equal [converters(:banking)], users(:operator).available_converters.to_a
  end

  test "admin receives every active converter" do
    assert_equal converters(:banking, :cards).sort_by(&:position), users(:admin).available_converters.to_a
  end
end
