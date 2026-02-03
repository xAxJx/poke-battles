class SelectedPokemonsController < ApplicationController
  def new
    @selected_all = SelectedPokemon.all
    @selected_pokemon = SelectedPokemon.new
    @selected_pokemon.pokemon_id = params[:pokemon_id]
    @pokemon_list = Pokemon.all
    @pokemon = Pokemon.find(params[:pokemon_id])
    @team = Team.find(params[:team_id])
    @game = Game.find(params[:game_id])
  end

  def create
    @selected_pokemon = SelectedPokemon.new(selected_pokemon_params)

    @team = Team.find(params[:team_id])
    @game = Game.find(params[:game_id])

    if @selected_pokemon.save
      redirect_to game_team_path(@game, @team)
    else
      raise
      render "new", status: :unprocessable_content # - but how do you pass the pokemon_id variable?
      # new_game_team_selected_pokemon_path(@game, @team)
    end

  end
  def show
    @selected_pokemon = SelectedPokemon.find(params[:id])
  end

  def edit
    @selected_pokemon = SelectedPokemon.find(params[:id])
    @selected_all = SelectedPokemon.all
    @game = Game.find(params[:game_id])
    @team = @selected_pokemon.team
  end

  def update
     @selected_pokemon = SelectedPokemon.find(params[:id])
     if @selected_pokemon.update(selected_pokemon_params)
       redirect_to game_team_path
     else
      render :edit
     end
  end

  def destroy
    @target_pokemon = SelectedPokemon.find(params[:id])
    @target_pokemon.destroy

    redirect_to game_team_path, status: :see_other
  end


  private
  def selected_pokemon_params
    params.require(:selected_pokemon).permit(:pokemon_id, :team_id, :move1, :move2, :move3, :move4, :game_id)
  end
end
