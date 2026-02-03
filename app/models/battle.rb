class Battle < ApplicationRecord
  belongs_to :game
  validates :game, presence: true

  has_many :actions, dependent: :destroy
  has_many :pokemons, -> { distinct }, through: :actions
  has_many :moves, -> { distinct }, through: :actions
end
