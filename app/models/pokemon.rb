class Pokemon < ApplicationRecord
  SELECTED_FK = SelectedPokemon.table_exists? && SelectedPokemon.column_names.include?("id_pokemons") ? :id_pokemons : :pokemon_id
  has_many :selected_pokemons, foreign_key: SELECTED_FK

end
