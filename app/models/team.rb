class Team < ApplicationRecord
  belongs_to :game
  SELECTED_FK = SelectedPokemon.table_exists? && SelectedPokemon.column_names.include?("id_Teams") ? :id_Teams : :team_id
  has_many :selected_pokemons, foreign_key: SELECTED_FK, dependent: :destroy
  has_many :pokemons, through: :selected_pokemons

  validates :opponent, presence: true #should have opponent to be a game
end
