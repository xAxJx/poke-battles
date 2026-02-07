class ActionsController < ApplicationController
  before_action :set_game
  before_action :set_battle

  def create
    player_team = player_team_for(@battle)
    opponent_team = opponent_team_for(@battle)
    @player_team_selected = selected_pokemons_for(@battle, player_team)
    @opponent_team_selected = opponent_team ? selected_pokemons_for(@battle, opponent_team) : SelectedPokemon.none
    initialize_hp_if_needed(@battle, @player_team_selected + @opponent_team_selected.to_a)

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
    params.fetch(:battle_action, {}).permit(:selected_pokemon_id, :id_selected_pokemons, :pokemon_id, :move_id)
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
      Team.find_by(game_id: @battle.game_id, opponent: "false") ||
      Team.find_by(game_id: @battle.game_id, opponent: "player") ||
      Team.where(game_id: @battle.game_id).where.not(opponent: "opponent").first
    return nil if player_team.nil?

    team_column = SelectedPokemon.column_names.include?("id_Teams") ? :id_Teams : :team_id
    pokemon_column = SelectedPokemon.column_names.include?("id_pokemons") ? :id_pokemons : :pokemon_id

    SelectedPokemon.find_by(team_column => player_team.id, pokemon_column => action_params[:pokemon_id])
  end

  def prepare_battle_state
    player_team = player_team_for(@battle)
    opponent_team = opponent_team_for(@battle)
    @player_team = player_team

    @player_team_selected = selected_pokemons_for(@battle, player_team)
    if opponent_team
      @opponent_team_selected = selected_pokemons_for(@battle, opponent_team)
    else
      @opponent_team_selected = SelectedPokemon.none
    end

    initialize_hp_if_needed(@battle, @player_team_selected + @opponent_team_selected.to_a)
    @player_active = active_selected_pokemon(@player_team_selected)
    @opponent_active = active_selected_pokemon(@opponent_team_selected)
    @recent_actions = @battle.actions.order(created_at: :desc).limit(10)
    @player_moves = moves_for_selected(@player_active)
    @battle_actions = Action.includes(:move, selected_pokemon: :pokemon)
                            .where(battle_id: @battle.id).order(created_at: :desc).limit(20).reverse
    @battle_over = battle_over?(@player_team_selected, @opponent_team_selected)
    @opponent_ready = opponent_team.present? && @opponent_team_selected.any?
    @battle_result = battle_result(@player_team_selected, @opponent_team_selected)
  end

  def selected_pokemons_for(battle, team)
    return SelectedPokemon.none if team.nil?

    scope = SelectedPokemon.includes(:pokemon)
    scope = scope.where(id_Battles: battle.id) if SelectedPokemon.column_names.include?("id_Battles")

    if SelectedPokemon.column_names.include?("id_Teams")
      scope.where(id_Teams: team.id).order(:id)
    else
      scope.where(team_id: team.id).order(:id)
    end
  end

  def active_selected_pokemon(selected_pokemons)
    selected_pokemons.detect { |selected| selected.hp_current.to_i > 0 } || selected_pokemons.first
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

  def initialize_hp_if_needed(battle, selected_pokemons)
    return if selected_pokemons.blank?

    any_nil = selected_pokemons.any? { |selected| selected.hp_current.nil? }
    any_zero_with_no_actions = battle.actions.none? && selected_pokemons.all? { |selected| selected.hp_current.to_i <= 0 }
    return unless any_nil || any_zero_with_no_actions

    selected_pokemons.each do |selected|
      pokemon = selected.pokemon
      max_hp = pokemon&.hp_max.to_i
      max_hp = pokemon&.HP_Max.to_i if max_hp <= 0 && pokemon.respond_to?(:HP_Max)
      max_hp = 50 if max_hp <= 0
      selected.update!(hp_current: max_hp)
    end
  end

  def moves_for_selected(selected_pokemon)
    return [] if selected_pokemon.nil?

    learned = selected_pokemon.learned_moves.includes(:move).map(&:move).compact
    return learned.first(4) if learned.any?

    raw_moves = [
      selected_pokemon.respond_to?(:move1) ? selected_pokemon.move1 : nil,
      selected_pokemon.respond_to?(:move2) ? selected_pokemon.move2 : nil,
      selected_pokemon.respond_to?(:move3) ? selected_pokemon.move3 : nil,
      selected_pokemon.respond_to?(:move4) ? selected_pokemon.move4 : nil
    ].compact

    move_ids = raw_moves.map { |value| value.to_i }.reject(&:zero?)
    moves_by_id = Move.where(id: move_ids).index_by(&:id)
    moves = move_ids.map { |move_id| moves_by_id[move_id] }.compact

    if moves.empty?
      moves = Move.where(name: raw_moves).index_by(&:name).values
    end

    moves.first(4)
  end

  def battle_over?(player_selected, opponent_selected)
    return false if opponent_selected.blank?
    player_alive = player_selected.any? { |selected| selected.hp_current.to_i > 0 }
    opponent_alive = opponent_selected.any? { |selected| selected.hp_current.to_i > 0 }
    !player_alive || !opponent_alive
  end

  def battle_result(player_selected, opponent_selected)
    return "Waiting for opponent" if opponent_selected.blank?
    player_alive = player_selected.any? { |selected| selected.hp_current.to_i > 0 }
    opponent_alive = opponent_selected.any? { |selected| selected.hp_current.to_i > 0 }
    return "Battle in progress" if player_alive && opponent_alive
    return "Player wins!" if player_alive && !opponent_alive
    return "Opponent wins!" if opponent_alive && !player_alive

    "Battle ended"
  end
end
