class DirectionsController < ApplicationController
  def show
    @direction = Direction.new(params)
    safe_route = @direction.calc_safe_route
    if safe_route
      render json: safe_route
    else
      render json: "There was a problem with one of your endpoints, make sure they are in the bay area and try again", status: 422
    end
  end
end