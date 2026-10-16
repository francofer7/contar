class User < ApplicationRecord
  PHONE_COUNTRY_CODES = Phonelib.phone_data.keys.grep(/\A[A-Z]{2}\z/).sort.freeze

  has_secure_password

  has_many :converter_assignments, dependent: :destroy
  has_many :assigned_converters, through: :converter_assignments, source: :converter

  enum :role, { operator: 0, admin: 1 }, default: :operator, validate: true

  normalizes :email, with: ->(email) { email.strip.downcase }

  before_validation :normalize_phone_number

  validates :name, presence: true, length: { maximum: 80 }
  validates :email,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone_country, inclusion: { in: PHONE_COUNTRY_CODES }
  validates :phone, presence: true
  validates :phone, phone: { allow_blank: true, country_specifier: :phone_country }
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

  private

  def normalize_phone_number
    return if phone.blank? || phone_country.blank?

    explicit_international = phone.match?(/\A\s*(?:\+|00)/)
    value = explicit_international ? phone : national_phone_input
    parsed = explicit_international ? Phonelib.parse(value) : Phonelib.parse(value, phone_country)
    return unless parsed.valid?

    self.phone = parsed.e164
    self.phone_country = parsed.country if explicit_international && parsed.country.present?
  end

  def national_phone_input
    digits = phone.gsub(/\D/, "")
    return phone unless phone_country == "AR" && !digits.start_with?("0", "9")

    "9#{digits}"
  end
end
