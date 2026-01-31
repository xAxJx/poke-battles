class MovesController < ApplicationController

  def index
    @moves = Move.all
  end
end
