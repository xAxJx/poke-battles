class SelectedPokemon < ApplicationRecord
  # belongs_to :team
  belongs_to :pokemon
  has_many :moves, through: learned_moves
end
