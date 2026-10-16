require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "normalizes email" do
    user = User.new(name: "Nueva", email: "  NUEVA@EXAMPLE.COM ", phone_country: "AR", phone: "351 555 9999", password: "password123")

    assert user.valid?
    assert_equal "nueva@example.com", user.email
    assert_equal "+5493515559999", user.phone
  end

  test "preserves a complete Argentine mobile number" do
    user = User.new(name: "Nueva", email: "nueva@example.com", phone_country: "AR", phone: "+54 9 351 555 9999", password: "password123")

    assert user.valid?
    assert_equal "+5493515559999", user.phone
  end

  test "normalizes a national number using the selected country" do
    user = User.new(name: "Nueva", email: "nueva@example.com", phone_country: "US", phone: "202 555 0123", password: "password123")

    assert user.valid?
    assert_equal "+12025550123", user.phone
    assert_equal "US", user.phone_country
  end

  test "rejects a number that is invalid for the selected country" do
    user = User.new(name: "Nueva", email: "nueva@example.com", phone_country: "US", phone: "123", password: "password123")

    assert_not user.valid?
    assert user.errors[:phone].present?
  end

  test "requires a phone number" do
    user = User.new(name: "Nueva", email: "nueva@example.com", password: "password123")

    assert_not user.valid?
    assert user.errors.added?(:phone, :blank)
  end

  test "operator only receives assigned active converters" do
    assert_equal [ converters(:banking) ], users(:operator).available_converters.to_a
  end

  test "admin receives every active converter" do
    assert_equal converters(:banking, :cards).sort_by(&:position), users(:admin).available_converters.to_a
  end
end
