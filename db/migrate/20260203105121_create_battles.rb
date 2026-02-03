class CreateBattles < ActiveRecord::Migration[7.1]
  def change
    create_table :battles do |t|
      t.references :game, null: false, foreign_key: true

      t.timestamps
    end
  end
end
