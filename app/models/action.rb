class Action < ApplicationRecord
  belongs_to :battle
  belongs_to :selected_pokemon
  belongs_to :move

  validates :battle, :selected_pokemon, :move, presence: true
  validate :selected_pokemon_in_battle

  private

  def selected_pokemon_in_battle
    return if battle.nil? || selected_pokemon.nil?
    selected_game_id = if selected_pokemon.respond_to?(:game_id) && selected_pokemon.game_id.present?
                         selected_pokemon.game_id
                       elsif selected_pokemon.respond_to?(:team) && selected_pokemon.team.present?
                         selected_pokemon.team.game_id
                       end
    return if selected_game_id.nil?

    errors.add(:selected_pokemon, "not in the battle") if selected_game_id != battle.game_id
  end
end
