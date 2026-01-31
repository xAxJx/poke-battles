class Team < ApplicationRecord
  belongs_to :game
  has_many :pokemons, dependent: :destroy #if game destroy then team destroy

  validates :opponent, presence: true #should have opponent to be a game
end
