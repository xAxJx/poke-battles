class ChangeDataTypeForHpMaxInPokemons < ActiveRecord::Migration[7.1]
  def change
    change_column :pokemons, :hp_max, :integer, using: 'hp_max::integer'
  end
end
