class Battle < ApplicationRecord
  belongs_to :game
  validates :game, presence: true

  has_many :actions, dependent: :destroy
  if SelectedPokemon.table_exists? && SelectedPokemon.column_names.include?("id_Battles")
    has_many :selected_pokemons, foreign_key: :id_Battles
    has_many :learned_moves, through: :selected_pokemons
  else
    has_many :selected_pokemons, through: :actions
    has_many :learned_moves, through: :selected_pokemons
  end
end
