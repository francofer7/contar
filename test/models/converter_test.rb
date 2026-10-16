require "test_helper"

class ConverterTest < ActiveSupport::TestCase
  test "only allows known source files" do
    converter = converters(:banking)
    converter.source_file = "../../secrets"

    assert_not converter.valid?
  end
end
