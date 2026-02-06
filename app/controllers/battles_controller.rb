class BattlesController < ApplicationController
  def new
    @game = Game.find(params[:game_id])

  end

  def show
    @battle = find_battle

    player_team = Team.find_by(game_id: @battle.game_id, opponent: [false, nil])
    opponent_team = Team.find_by(game_id: @battle.game_id, opponent: true)
    player_team ||= Team.find_by(game_id: @battle.game_id, opponent: "false")
    opponent_team ||= Team.find_by(game_id: @battle.game_id, opponent: "true")

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

  private

  def find_battle
    if params[:id].present? && params[:id].to_s.match?(/\A\d+\z/)
      Battle.find(params[:id])
    elsif params[:game_id].present?
      Battle.find_by!(game_id: params[:game_id])
    else
      raise ActiveRecord::RecordNotFound, "Battle not found"
    end
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
