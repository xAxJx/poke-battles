class Battle < ApplicationRecord
  belongs_to :game
  validates :game, presence: true

  has_many :actions, dependent: :destroy
  has_many :selected_pokemons, through: :actions
  has_many :learned_moves, through: :selected_pokemons
end
