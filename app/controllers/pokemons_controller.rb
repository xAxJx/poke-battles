class PokemonsController < ApplicationController
  def index
    @pokemons = Pokemon.all
  end

  def search
    @search = params[:search]
    @pokemons = Pokemon.where("name LIKE '%#{@search}%'")
  end
end
