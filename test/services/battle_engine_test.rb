require "test_helper"

class BattleEngineTest < ActiveSupport::TestCase
  test "play_turn creates actions and applies damage" do
    user = User.create!(email: "trainer@example.com", password: "password")
    game = Game.create!(user: user, status: "in_battle")
    battle = Battle.create!(game: game)

    player_team = Team.create!(game: game, opponent: "false")
    opponent_team = Team.create!(game: game, opponent: "true")

    player_pokemon = Pokemon.create!(name: "Alpha", number: 1, hp_max: 30)
    opponent_pokemon = Pokemon.create!(name: "Beta", number: 2, hp_max: 30)

    player_selected = SelectedPokemon.create!(pokemon: player_pokemon, team: player_team, hp_current: 30)
    opponent_selected = SelectedPokemon.create!(pokemon: opponent_pokemon, team: opponent_team, hp_current: 30)

    move = Move.create!(name: "Tackle", power: 10)
    LearnedMove.create!(selected_pokemon: opponent_selected, move: move)

    assert_difference("Action.count", 2) do
      result = BattleEngine.play_turn!(
        battle: battle,
        player_selected_pokemon: player_selected,
        player_move_id: move.id
      )

      assert result[:player_action_id].present?
      assert result[:opponent_action_id].present?
      assert result[:player_damage] >= 1
      assert result[:opponent_damage] >= 1
    end

    assert player_selected.reload.hp_current < 30
    assert opponent_selected.reload.hp_current < 30
  end
end
