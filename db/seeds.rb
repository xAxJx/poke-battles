# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
#
puts "Cleaning database"
Pokemon.destroy_all

puts "Accessing API"

require 'json'
require 'open-uri'

# pokeapi_url = "https://pokeapi.co/api/v2/pokemon?limit=151"

# file = URI.parse(pokeapi_url).read
# hash = JSON.parse(file)

# puts hash["results"]

puts "Populating Pokemon"
(1..151).each do |number|

poke_url = "https://pokeapi.co/api/v2/pokemon/#{number}"

file_poke = URI.parse(poke_url).read
hash_poke = JSON.parse(file_poke)

poke = Pokemon.new(
name: hash_poke["name"],
number: hash_poke["id"],
picture: hash_poke["sprites"]["front_default"],
type1: hash_poke["types"][0]["type"]["name"],
type2: "",
hp_max: hash_poke["stats"][0]["base_stat"],
hp_current: 0,
attack: hash_poke["stats"][1]["base_stat"],
defense: hash_poke["stats"][2]["base_stat"],
sp_attack: hash_poke["stats"][3]["base_stat"],
sp_defense: hash_poke["stats"][4]["base_stat"],
speed: hash_poke["stats"][5]["base_stat"],
move1: "vine whip",
move2: "leech seed",
move3: "tackle",
move4: "growl"
)

  if hash_poke["types"][1]
    poke.type2 = hash_poke["types"][1]["type"]["name"]
  end

poke.save!
end

puts "Saved #{Pokemon.count} Pokemon to database."

# poke = Pokemon.new(
# name: "Bulbasaur",
# number: 1,
# picture: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png",
# type1: "grass",
# type2: "poison",
# hp_max: 49,
# hp_current: 0,
# attack: 49,
# defense: 49,
# sp_attack: 49,
# sp_defense: 49,
# speed: 45,
# move1: "vine whip",
# move2: "leech seed",
# move3: "tackle",
# move4: "growl"
# )
# poke.save!


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


# Moves
puts "Cleaning move list"
Move.destroy_all

puts "Populating move list"


(1..165).each do |number|

    move_url = "https://pokeapi.co/api/v2/move/#{number}"

    file_move = URI.parse(move_url).read
    hash_move = JSON.parse(file_move)

    move = Move.new(
      move_id: hash_move["id"],
      name: hash_move["name"],
      move_type: hash_move["type"]["name"],
      power: hash_move["power"],
      accuracy: hash_move["accuracy"],
      damage_class: hash_move["damage_class"]["name"],
      description: hash_move["flavor_text_entries"][0]["flavor_text"],
      effect_chance: hash_move["effect_chance"],
      effect: hash_move["effect_entries"][1]["effect"]
    )
    move.save!
  end

puts "Added #{Move.count} moves.";

# Seed dummy values
dummyuser = User.first
dummygame = Game.create!(user_id: dummyuser.id, status: "dummy")
dummyteam = Team.create!(game_id: dummygame.id, opponent: "dummy")
dummypoke = SelectedPokemon.create!(pokemon_id: Pokemon.last.id, team_id: dummyteam.id, move1: "thunder", move2: "blizard", move3: "earthquake", move4: "flamethrower")
dummypoke.save

puts "Seeded dummies"

# Seed opponent teams
# bossGame = Game.create(user_id: dummyuser.id, status: "boss" )
# red = Team.create!(game_id: bossGame.id, opponent: "boss")
# redPoke1 = SelectedPokemon.new(pokemon_id: Pokemon.where(number: 3, team_id: red.id))
# redPoke1.save
