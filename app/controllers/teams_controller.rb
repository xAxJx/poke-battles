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
    @team = Team.new(team_params)

    # Manually attach the team to the current game
    # does game_id comes from the URL or the form, my logic is that it comes from the url
    @team.game = @game

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
  end

  # GET /games/:game_id/teams/:id/edit
  # Shows the edit form
  def edit
    # No logic here yet just the form
  end

end
