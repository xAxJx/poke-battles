# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Populating Pokemon"

poke = Pokemon.new(
name: "Bulbasaur",
number: 1,
picture: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png",
type1: "grass",
type2: "poison",
hp_max: 49,
hp_current: 0,
attack: 49,
defense: 49,
sp_attack: 49,
sp_defense: 49,
speed: 45,
move1: "vine whip",
move2: "leech seed",
move3: "tackle",
move4: "growl"
)
poke.save!


# poke = Pokemon.new(
# name: "",
# number: ,
# picture: "",
# type: "",
# type2: "",
# hp_max: ,
# hp_current: ,
# attack: ,
# defense: ,
# sp_attack: ,
# sp_defense: ,
# speed: ,
# move1: "",
# move2: "",
# move3: "",
# move4: ""
# )
# poke.save!
