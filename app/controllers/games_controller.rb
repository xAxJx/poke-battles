# creating the games controller inherenting from applicationcontroller sessions, Devise , filters (game params), private class
class GamesController < ApplicationController
  before_action :set_game, only: [:show]

  # Creating an empty Game object
  def new
    @game = Game.new
  end

  # create new game
  def create

    @game = Game.new
    @game.user = current_user
    @game.status ||= "setup"  # Make sure the game starts in "setup" state
    generate_pokemon

    if @game.save
      redirect_to game_path(@game)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @selected = SelectedPokemon.all
    @pokemons = Pokemon.all
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  # def game_params
  #   params.fetch(:game, {}).permit(:status)
  # end
  #
  def generate_opponent
    @game = Game.find(params[:id])
    @newOpponent = Team.create!(game_id:@game.id, opponent:"opponent")
    # @randPoke1 = Pokemon.find_by(number:rand(1..151))
    @randPokemons = Pokemon.all.sample(3)
    @randMoves1 = Move.all.sample(4)
    @randMoves2 = Move.all.sample(4)
    @randMoves3 = Move.all.sample(4)
    @opponentPoke1 = SelectedPokemon.create!(team_id:@newOpponent.id, pokemon_id:@randPokemons[0].id, move1:@randMoves1[0].id, move2:@randMoves1[1].id, move3:@randMoves1[2].id, move4:@randMoves[3].id,)
    @opponentPoke2 = SelectedPokemon.create!(team_id:@newOpponent.id, pokemon_id:@randPokemons[1].id, move1:@randMoves2[0].id, move2:@randMoves2[1].id, move3:@randMoves2[2].id, move4:@randMoves[3].id,)
    @opponentPoke3 = SelectedPokemon.create!(team_id:@newOpponent.id, pokemon_id:@randPokemons[2].id, move1:@randMoves3[0].id, move2:@randMoves3[1].id, move3:@randMoves3[2].id, move4:@randMoves[3].id,)
  end

  def generate_opponent_pokemon

  end
end
