class TeamsController < ApplicationController
  # We are always inside a game (teams are nested under games)...
  # so we load the game first for every action
  before_action :set_game

  # For pages that deal with an existing team,
  # load the team that belongs to this game
  before_action :set_team, only: [:show, :edit]

  # GET /games/:game_id/teams/new
  # Shows the form to create a team
  def new
    # Empty team object for the form
    @team = Team.new
  end

  # POST /games/:game_id/teams
  # Actually create the team in the DB
  def create
    # Build a team from the form params
    @team = Team.new #(team_params) doesn't work

    # Manually attach the team to the current game
    # does game_id comes from the URL or the form, my logic is that it comes from the url ???
    @team.game = @game
    # set the opponent status to "player"
    @team.opponent = "player"
    generate_opponent

    if @team.save
      # If everything is OK, go to the team page
      redirect_to game_team_path(@game, @team)
    else
      # If something is wrong, show the form again
      # and keep the errors
      render :new, status: :unprocessable_entity
    end
  end

  # GET /games/:game_id/teams/:id
  # Just displays the team
  def show
    # @team is already set by set_team
    @pokemons = Pokemon.all
    @selected_pokemon = SelectedPokemon.all
  end

  # GET /games/:game_id/teams/:id/edit
  # Shows the edit form
  def edit
    # No logic here yet just the form
  end

  private

  # Finds the game from the URL

  def set_game
    @game = Game.find(params[:game_id])
  end

  # Finds the team, but scoped to the current game
  # This avoids someone accessing a team from another game
  def set_team
    @team = @game.teams.find(params[:id])
  end

  # only allow what the form is supposed to send
  # def team_params
  #   params.require(:team).permit(:opponent)
  # end
  private

  def generate_opponent
    @currentGame = Game.find(params[:game_id])
    @newOpponent = Team.create!(game_id:@currentGame.id, opponent:"opponent")
    # @randPoke1 = Pokemon.find_by(number:rand(1..151))
    @randPokemons = Pokemon.all.sample(3)
    @randMoves1 = Move.all.sample(4)
    @randMoves2 = Move.all.sample(4)
    @randMoves3 = Move.all.sample(4)
    @opponentPoke1 = SelectedPokemon.create!(team_id:@newOpponent.id, pokemon_id:@randPokemons[0].id, move1:@randMoves1[0].id, move2:@randMoves1[1].id, move3:@randMoves1[2].id, move4:@randMoves1[3].id,)
    @opponentPoke2 = SelectedPokemon.create!(team_id:@newOpponent.id, pokemon_id:@randPokemons[1].id, move1:@randMoves2[0].id, move2:@randMoves2[1].id, move3:@randMoves2[2].id, move4:@randMoves2[3].id,)
    @opponentPoke3 = SelectedPokemon.create!(team_id:@newOpponent.id, pokemon_id:@randPokemons[2].id, move1:@randMoves3[0].id, move2:@randMoves3[1].id, move3:@randMoves3[2].id, move4:@randMoves3[3].id,)
  end

end
