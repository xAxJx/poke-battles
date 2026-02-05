class SelectedPokemon < ApplicationRecord
  belongs_to :team
  belongs_to :pokemon
  has_many :moves, through: :learned_moves

  MAX_TEAM_SIZE = 3

  validate :max_team_size

  def max_team_size
    if (SelectedPokemon.where(team_id: team_id).size >= MAX_TEAM_SIZE)
      errors.add("Max team size is #{MAX_TEAM_SIZE} Pokemon.")
    end
  end
end
