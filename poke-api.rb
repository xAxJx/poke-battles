require 'json'
require 'open-uri'

pokeapi_url = "https://pokeapi.co/api/v2/pokemon?limit=1"

file = URI.parse(pokeapi_url).read
hash = JSON.parse(file)

puts hash["results"]

poke_url = "https://pokeapi.co/api/v2/pokemon/1"

file_poke = URI.parse(poke_url).read
hash_poke = JSON.parse(file_poke)

# name
puts hash_poke["name"]
# type (some have 2 types)
puts hash_poke["types"][0]["type"]["name"]
puts hash_poke["types"][1]["type"]["name"]
# picture
puts hash_poke["sprites"]["front_default"]

# stats
(0..5).each do |stat|
  puts "#{hash_poke["stats"][stat]["stat"]["name"]} : #{hash_poke["stats"][stat]["base_stat"]}"
end

# moves (this one gets big)
# puts hash_poke["moves"]
