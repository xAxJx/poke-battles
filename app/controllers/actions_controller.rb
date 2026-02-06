class ActionsController < ApplicationController
  before_action :set_game
  before_action :set_battle

  def create
    player_selected_pokemon = resolve_selected_pokemon

    result = BattleEngine.play_turn!(
      battle: @battle,
      player_selected_pokemon: player_selected_pokemon,
      player_move_id: action_params[:move_id]
    )
    @action = Action.find_by(id: result[:player_action_id])

    if @action
      redirect_to game_battle_path(@game, @battle)
    else
      render "battles/show", status: :unprocessable_entity
    end
  rescue ArgumentError, ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.message
    render "battles/show", status: :unprocessable_entity
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  end

  def set_battle
    @battle = @game.battles.find(params[:battle_id])
  end

  def action_params
    params.require(:action).permit(:selected_pokemon_id, :pokemon_id, :move_id)
  end

  def resolve_selected_pokemon
    if action_params[:selected_pokemon_id].present?
      return SelectedPokemon.find(action_params[:selected_pokemon_id])
    end

    return nil if action_params[:pokemon_id].blank?

    player_team = Team.find_by(game_id: @battle.game_id, opponent: [false, nil]) ||
      Team.find_by(game_id: @battle.game_id, opponent: "false")
    return nil if player_team.nil?

    team_column = SelectedPokemon.column_names.include?("id_Teams") ? :id_Teams : :team_id
    pokemon_column = SelectedPokemon.column_names.include?("id_pokemons") ? :id_pokemons : :pokemon_id

    SelectedPokemon.find_by(team_column => player_team.id, pokemon_column => action_params[:pokemon_id])
  end
end
