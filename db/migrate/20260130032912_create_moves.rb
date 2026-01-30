class CreateMoves < ActiveRecord::Migration[7.1]
  def change
    create_table :moves do |t|
      t.integer :move_id
      t.string :name
      t.string :move_type
      t.integer :power
      t.integer :accuracy
      t.string :damage_class
      t.text :description
      t.integer :effect_chance
      t.text :effect

      t.timestamps
    end
  end
end
