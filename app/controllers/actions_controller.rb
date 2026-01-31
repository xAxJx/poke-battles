class ActionsController < ApplicationController
  def new
    @action = Action.new
  end
  def create
    @action = Action.new(action_params)
  end

  private

  def action_params
    params.require(:action).permit(:pokemon_id, :move_id)
  end
end
