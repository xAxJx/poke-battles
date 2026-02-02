class Action < ApplicationRecord
  belongs_to :battle
  belongs_to :pokemon
  belongs_to :move

  validates :battle, :pokemon, :move, presence: true
  validate :pokemon_in_battle

  private

  def pokemon_in_battle
    unless battle.pokemons.include?(pokemon)
      errors.add(:pokemon, "not in the battle")
    end
  end
end
