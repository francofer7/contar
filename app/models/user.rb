class User < ApplicationRecord
  has_secure_password

  has_many :converter_assignments, dependent: :destroy
  has_many :assigned_converters, through: :converter_assignments, source: :converter

  enum :role, { operator: 0, admin: 1 }, default: :operator, validate: true

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, presence: true, length: { maximum: 80 }
  validates :email,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }

  scope :active, -> { where(active: true) }

  def available_converters
    admin? ? Converter.active.ordered : assigned_converters.active.ordered
  end

  def converter_ids
    assigned_converter_ids
  end

  def converter_ids=(ids)
    self.assigned_converter_ids = ids
  end
end
