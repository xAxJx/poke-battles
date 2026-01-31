class AddTeamRefToSelectedPokemons < ActiveRecord::Migration[7.1]
  def change
    add_reference :selected_pokemons, :team, null: false, foreign_key: true
  end
end
