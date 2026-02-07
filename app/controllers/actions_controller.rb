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
      prepare_battle_state
      render "battles/show", status: :unprocessable_entity
    end
  rescue ArgumentError, ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.message
    prepare_battle_state
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
    params.require(:action).permit(:selected_pokemon_id, :id_selected_pokemons, :pokemon_id, :move_id)
  end

  def resolve_selected_pokemon
    if action_params[:selected_pokemon_id].present?
      return SelectedPokemon.find(action_params[:selected_pokemon_id])
    end

    if action_params[:id_selected_pokemons].present?
      return SelectedPokemon.find(action_params[:id_selected_pokemons])
    end

    return nil if action_params[:pokemon_id].blank?

    player_team = Team.find_by(game_id: @battle.game_id, opponent: [false, nil]) ||
      Team.find_by(game_id: @battle.game_id, opponent: "false")
    return nil if player_team.nil?

    team_column = SelectedPokemon.column_names.include?("id_Teams") ? :id_Teams : :team_id
    pokemon_column = SelectedPokemon.column_names.include?("id_pokemons") ? :id_pokemons : :pokemon_id

    SelectedPokemon.find_by(team_column => player_team.id, pokemon_column => action_params[:pokemon_id])
  end

  def prepare_battle_state
    player_team = Team.find_by(game_id: @battle.game_id, opponent: [false, nil]) ||
      Team.find_by(game_id: @battle.game_id, opponent: "false")
    opponent_team = Team.find_by(game_id: @battle.game_id, opponent: true) ||
      Team.find_by(game_id: @battle.game_id, opponent: "true")

    @player_team_selected = selected_pokemons_for(@battle, player_team)
    if opponent_team
      @opponent_team_selected = selected_pokemons_for(@battle, opponent_team)
    else
      @opponent_team_selected = SelectedPokemon.none
    end

    @player_active = active_selected_pokemon(@player_team_selected)
    @opponent_active = active_selected_pokemon(@opponent_team_selected)
    @recent_actions = @battle.actions.order(created_at: :desc).limit(10)
  end

  def selected_pokemons_for(battle, team)
    return SelectedPokemon.none if team.nil?

    scope = SelectedPokemon.all
    scope = scope.where(id_Battles: battle.id) if SelectedPokemon.column_names.include?("id_Battles")

    if SelectedPokemon.column_names.include?("id_Teams")
      scope.where(id_Teams: team.id)
    else
      scope.where(team_id: team.id)
    end
  end

  def active_selected_pokemon(selected_pokemons)
    selected_pokemons.detect { |selected| selected.hp_current.to_i > 0 } || selected_pokemons.first
  end
end
