class Team < ApplicationRecord
  belongs_to :game
  has_many :pokemons, dependent: :destroy

  validates :opponent, presence: true
end
