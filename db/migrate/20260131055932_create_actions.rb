class CreateActions < ActiveRecord::Migration[7.1]
  def change
    create_table :actions do |t|
      t.references :game, null: false, foreign_key: true
      t.references :pokemon, null: false, foreign_key: true
      t.references :move, null: false, foreign_key: true

      t.timestamps
    end
  end
end
