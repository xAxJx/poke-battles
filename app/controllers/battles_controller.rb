class BattlesController < ApplicationController
  def new
    @game = Game.find(params[:game_id])
  end

  def create
    @game = Game.find(params[:game_id])
    @battle = @game.battles.order(created_at: :desc).first || @game.battles.create!

    redirect_to game_battle_path(@game, @battle)
  end

  def show
    @battle = find_battle

    player_team = player_team_for(@battle)
    opponent_team = opponent_team_for(@battle)

    @player_team_selected = selected_pokemons_for(@battle, player_team)
    @opponent_team_selected = opponent_team ? selected_pokemons_for(@battle, opponent_team) : SelectedPokemon.none

    @player_active = first_selected_pokemon(@player_team_selected)
    @opponent_active = first_selected_pokemon(@opponent_team_selected)
    @recent_actions = @battle.actions.order(created_at: :desc).limit(10)

    Rails.logger.debug { "BattlesController#show battle_id=#{@battle.id} game_id=#{@battle.game_id}" }
    Rails.logger.debug { "BattlesController#show player_team_id=#{player_team&.id} opponent_team_id=#{opponent_team&.id}" }
    Rails.logger.debug do
      "BattlesController#show player_selected=#{@player_team_selected.size} opponent_selected=#{@opponent_team_selected.size}"
    end
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

    scope = SelectedPokemon.includes(:pokemon)

    battle_key = if SelectedPokemon.column_names.include?("id_Battles")
                   :id_Battles
                 elsif SelectedPokemon.column_names.include?("battle_id")
                   :battle_id
                 end
    team_key = SelectedPokemon.column_names.include?("id_Teams") ? :id_Teams : :team_id

    scope = scope.where(battle_key => battle.id) if battle_key
    scope.where(team_key => team.id).order(:id)
  end

  def first_selected_pokemon(selected_pokemons)
    selected_pokemons.first
  end

  def player_team_for(battle)
    Team.find_by(game_id: battle.game_id, opponent: [false, nil]) ||
      Team.find_by(game_id: battle.game_id, opponent: "false") ||
      Team.find_by(game_id: battle.game_id, opponent: "player") ||
      Team.where(game_id: battle.game_id).where.not(opponent: "opponent").first
  end

  def opponent_team_for(battle)
    Team.find_by(game_id: battle.game_id, opponent: true) ||
      Team.find_by(game_id: battle.game_id, opponent: "true") ||
      Team.find_by(game_id: battle.game_id, opponent: "opponent")
  end
end
