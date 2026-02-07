class Pokemon < ApplicationRecord
  has_many :selected_pokemons, dependent: :destroy

end
