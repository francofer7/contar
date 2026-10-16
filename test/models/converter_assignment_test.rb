require "test_helper"

class ConverterAssignmentTest < ActiveSupport::TestCase
  test "does not duplicate an assignment" do
    duplicate = ConverterAssignment.new(user: users(:operator), converter: converters(:banking))

    assert_not duplicate.valid?
  end
end
