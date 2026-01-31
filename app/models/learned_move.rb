class LearnedMove < ApplicationRecord
  belongs_to :selected_pokemon
  belongs_to :move
end
