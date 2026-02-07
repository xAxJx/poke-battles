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
    @player_team = player_team

    @player_team_selected = selected_pokemons_for(@battle, player_team)
    @opponent_team_selected = opponent_team ? selected_pokemons_for(@battle, opponent_team) : SelectedPokemon.none

    initialize_hp_if_needed(@battle, @player_team_selected + @opponent_team_selected.to_a)

    @player_active = active_selected_pokemon(@player_team_selected)
    @opponent_active = active_selected_pokemon(@opponent_team_selected)
    @recent_actions = @battle.actions.order(created_at: :desc).limit(10)
    @battle_actions = Action.includes(:move, selected_pokemon: :pokemon)
                            .where(battle_id: @battle.id).order(created_at: :desc).limit(20).reverse

    @player_moves = moves_for_selected(@player_active)
    @battle_over = battle_over?(@player_team_selected, @opponent_team_selected)
    @opponent_ready = opponent_team.present? && @opponent_team_selected.any?
    @battle_result = battle_result(@player_team_selected, @opponent_team_selected)

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
