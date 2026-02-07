class Game < ApplicationRecord
  belongs_to :user
  has_many :teams, dependent: :destroy
  has_many :battles, dependent: :destroy
  has_many :actions, dependent: :destroy
  has_many :my_items, dependent: :destroy
  has_many :items, through: :my_items

  STATUSES = %w[setup in_battle finished dummy].freeze

  validates :status, inclusion: { in: STATUSES }, allow_nil: true
end
