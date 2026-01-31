# creating the games controller inherenting from applicationcontroller sessions, Devise , filters (game params), private class
class GamesController < ApplicationController
  before_action :set_game, only: [:show]

  # Creating an empty Game object
  def new
    @game = Game.new
  end

  # create new game
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
