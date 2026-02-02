class AddMoveToSelectedPokemon < ActiveRecord::Migration[7.1]
  def change
    add_column :selected_pokemons, :move1, :string
    add_column :selected_pokemons, :move2, :string
    add_column :selected_pokemons, :move3, :string
    add_column :selected_pokemons, :move4, :string
  end
end
