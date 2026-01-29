class CreatePokemons < ActiveRecord::Migration[7.1]
  def change
    create_table :pokemons do |t|
      t.text :name
      t.integer :number
      t.string :picture
      t.string :type
      t.string :type2
      t.string :hp_max
      t.string :integer
      t.integer :hp_current
      t.integer :attack
      t.integer :defense
      t.integer :sp_attack
      t.integer :sp_defense
      t.integer :speed
      t.string :move1
      t.string :move2
      t.string :move3
      t.string :move4

      t.timestamps
    end
  end
end
