class Action < ApplicationRecord
  belongs_to :battle
  belongs_to :selected_pokemon
  belongs_to :move

  validates :battle, :selected_pokemon, :move, presence: true
  validate :pokemon_in_battle

  private

  def selected_pokemon_in_battle
    return if battle.nil? || selected_pokemon.nil?
    unless selected_pokemon.game_id == battle.game_id
      errors.add(:pokemon, "not in the battle")
    end
  end
end
