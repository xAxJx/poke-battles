class CreateActions < ActiveRecord::Migration[7.1]
  def change
    create_table :actions do |t|
      t.references :battle, null: false, foreign_key: true
      t.references :selected_pokemon, null: false, foreign_key: true
      t.references :move, null: false, foreign_key: true

      t.timestamps
    end
  end
end
