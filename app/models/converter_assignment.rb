class ConverterAssignment < ApplicationRecord
  belongs_to :user
  belongs_to :converter

  validates :converter_id, uniqueness: { scope: :user_id }
end
