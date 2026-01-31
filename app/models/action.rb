class Action < ApplicationRecord
  belongs_to :game
  belongs_to :pokemon
  belongs_to :move
end
