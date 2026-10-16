class Converter < ApplicationRecord
  has_many :converter_assignments, dependent: :destroy
  has_many :users, through: :converter_assignments

  validates :key, :name, :description, :source_file, presence: true
  validates :key, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }
  validates :source_file, inclusion: { in: %w[banking.html cards.html] }

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position, :name) }
end
