class CreateBattlesAndActions < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:battles)
      create_table :battles do |t|
        t.references :game, null: false, foreign_key: true

        t.timestamps
      end
    end

    unless table_exists?(:actions)
      create_table :actions do |t|
        t.references :battle, null: false, foreign_key: true
        t.references :selected_pokemon, null: false, foreign_key: true
        t.references :move, null: false, foreign_key: true

        t.timestamps
      end
    end
  end
end
