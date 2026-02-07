class SelectedPokemon < ApplicationRecord
  TEAM_FK = table_exists? && column_names.include?("id_Teams") ? :id_Teams : :team_id
  POKEMON_FK = table_exists? && column_names.include?("id_pokemons") ? :id_pokemons : :pokemon_id
  BATTLE_FK = if table_exists? && (column_names.include?("id_Battles") || column_names.include?("battle_id"))
                column_names.include?("id_Battles") ? :id_Battles : :battle_id
              end

  belongs_to :team, foreign_key: TEAM_FK
  belongs_to :pokemon, foreign_key: POKEMON_FK
  belongs_to :battle, foreign_key: BATTLE_FK, optional: true if BATTLE_FK
  has_many :learned_moves, dependent: :destroy
  has_many :moves, through: :learned_moves

  MAX_TEAM_SIZE = 3

  validate :max_team_size, on: :create

  def max_team_size
    team_key = self.class::TEAM_FK.to_s
    team_value = respond_to?(team_key) ? public_send(team_key) : team_id
    return if team_value.blank?

    if SelectedPokemon.where(team_key => team_value).size >= MAX_TEAM_SIZE
      errors.add("Max team size is #{MAX_TEAM_SIZE} Pokemon.")
    end
  end
end
