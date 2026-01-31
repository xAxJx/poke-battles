class CreateSelectedPokemons < ActiveRecord::Migration[7.1]
  def change
    create_table :selected_pokemons do |t|
      # t.references :team, null: false, foreign_key: true
      t.references :pokemon, null: false, foreign_key: true
      t.integer :hp_current
      t.integer :exp
      t.string :status
      t.string :ability

      t.timestamps
    end
  end
end
