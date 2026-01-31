class CreateLearnedMoves < ActiveRecord::Migration[7.1]
  def change
    create_table :learned_moves do |t|
      t.references :selected_pokemon, null: false, foreign_key: true
      t.references :move, null: false, foreign_key: true

      t.timestamps
    end
  end
end
