class GamesController < ApplicationController
  before_action :set_game, only: [:show]

  def new
    @game = Game.new
  end

  def create
    @game = Game.new(game_params)
    @game.user = current_user
    @game.status ||= "setup"

    if @game.save
      redirect_to game_path(@game)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def game_params
    params.fetch(:game, {}).permit(:status)
  end
end
