class ActionsController < ApplicationController
  before_action :set_game
  before_action :set_battle

  def create
    @action = Action.new(action_params)
    @action.battle = @battle

    if @action.save
      redirect_to game_battle_path(@game, @battle)
    else
      render "battles/show", status: :unprocessable_entity
    end
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  end

  def set_battle
    @battle = @game.battles.find(params[:battle_id])
  end

  def action_params
    params.require(:action).permit(:pokemon_id, :move_id)
  end
end
