class BattleEngine
  def self.play_turn!(battle:, player_selected_pokemon:, player_move_id:)
    player_team = player_team_for(battle)
    unless player_team && player_selected_pokemon_in_team?(player_selected_pokemon, player_team, battle)
      raise ArgumentError, "Selected pokemon is not on the player team for this battle"
    end

    player_action = Action.create!(
      battle: battle,
      selected_pokemon: player_selected_pokemon,
      move_id: player_move_id
    )

    opponent_selected_pokemon = opponent_active_for(battle)
    if opponent_selected_pokemon.nil?
      return {
        player_action_id: player_action.id,
        opponent_action_id: nil,
        player_damage: 0,
        opponent_damage: 0,
        player_hp_after: player_selected_pokemon.hp_current.to_i,
        opponent_hp_after: nil,
        player_fainted: player_selected_pokemon.hp_current.to_i <= 0,
        opponent_fainted: false,
        opponent_missing: true
      }
    end

    opponent_move_id = opponent_move_for(battle, opponent_selected_pokemon)
    opponent_action = Action.create!(
      battle: battle,
      selected_pokemon: opponent_selected_pokemon,
      move_id: opponent_move_id
    )

    player_damage = damage_for_move(player_move_id)
    opponent_damage = damage_for_move(opponent_move_id)

    opponent_hp_after = apply_damage!(opponent_selected_pokemon, player_damage)
    player_hp_after = apply_damage!(player_selected_pokemon, opponent_damage)

    {
      player_action_id: player_action.id,
      opponent_action_id: opponent_action.id,
      player_damage: player_damage,
      opponent_damage: opponent_damage,
      player_hp_after: player_hp_after,
      opponent_hp_after: opponent_hp_after,
      player_fainted: player_hp_after <= 0,
      opponent_fainted: opponent_hp_after <= 0,
      opponent_missing: false
    }
  end

  def self.opponent_move_for(_battle, opponent_selected_pokemon)
    # TODO: Replace with AI logic later
    learned_move_ids = learned_moves_for(opponent_selected_pokemon).pluck(:move_id)
    return learned_move_ids.sample if learned_move_ids.any?

    Move.pluck(:id).sample
  end

  def self.damage_for_move(move_id)
    move = Move.find_by(id: move_id)
    power = if move && move.respond_to?(:move_power) && move.move_power.present?
              move.move_power
            elsif move && move.respond_to?(:power) && move.power.present?
              move.power
            else
              10
            end

    [power.to_i, 1].max
  end

  def self.apply_damage!(selected_pokemon, damage)
    current_hp = selected_pokemon.hp_current.to_i
    updated_hp = [current_hp - damage, 0].max
    selected_pokemon.update!(hp_current: updated_hp)
    updated_hp
  end

  def self.player_team_for(battle)
    Team.find_by(game_id: battle.game_id, opponent: [false, nil]) ||
      Team.find_by(game_id: battle.game_id, opponent: "false")
  end

  def self.opponent_team_for(battle)
    Team.find_by(game_id: battle.game_id, opponent: true) ||
      Team.find_by(game_id: battle.game_id, opponent: "true")
  end

  def self.player_selected_pokemon_in_team?(selected_pokemon, player_team, battle)
    return false if selected_pokemon.nil? || player_team.nil?

    team_id = if selected_pokemon.respond_to?(:id_Teams) && selected_pokemon.id_Teams.present?
                selected_pokemon.id_Teams
              else
                selected_pokemon.team_id
              end

    return false unless team_id == player_team.id

    if selected_pokemon.respond_to?(:id_Battles) && selected_pokemon.id_Battles.present?
      return false unless selected_pokemon.id_Battles == battle.id
    end

    true
  end

  def self.opponent_active_for(battle)
    opponent_team = opponent_team_for(battle)
    return nil if opponent_team.nil?

    scope = SelectedPokemon.all
    if SelectedPokemon.column_names.include?("id_Battles")
      scope = scope.where(id_Battles: battle.id)
    end

    if SelectedPokemon.column_names.include?("id_Teams")
      scope = scope.where(id_Teams: opponent_team.id)
    else
      scope = scope.where(team_id: opponent_team.id)
    end

    scope.detect { |selected| selected.hp_current.to_i > 0 } || scope.first
  end

  def self.learned_moves_for(selected_pokemon)
    if LearnedMove.column_names.include?("id_selected_pokemons")
      LearnedMove.where(id_selected_pokemons: selected_pokemon.id)
    else
      LearnedMove.where(selected_pokemon_id: selected_pokemon.id)
    end
  end

  private_class_method :opponent_move_for,
                       :damage_for_move,
                       :apply_damage!,
                       :player_team_for,
                       :opponent_team_for,
                       :player_selected_pokemon_in_team?,
                       :opponent_active_for,
                       :learned_moves_for
end
