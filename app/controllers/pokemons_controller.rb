class PokemonsController < ApplicationController
  skip_before_action:authenticate_user!, only: [:index, :search]
  def index
    @pokemons = Pokemon.all.order(params[:sort])

    if params[:direction] == "desc"
      @pokemons = Pokemon.all.order(params[:sort]).reverse_order
    end
  end

  def search
    @search = params[:search]
    @pokemons = Pokemon.where("name LIKE '%#{@search}%'")
  end

  private
  #sanitize and set default
  def sort_direction
  end
end
