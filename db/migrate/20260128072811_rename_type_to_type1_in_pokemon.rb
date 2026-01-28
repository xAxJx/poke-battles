class RenameTypeToType1InPokemon < ActiveRecord::Migration[7.1]
  def change
    rename_column :pokemons, :type, :type1
  end
end
