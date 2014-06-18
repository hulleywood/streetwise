class DirectionsController < ApplicationController
  def show
    @direction = Direction.new(params)
    if valid_request
      safe_route = @direction.calc_safe_route
      if safe_route
        render json: safe_route
      else
        render json: "Something went wrong, please try again", status: 422
      end
    else
      render json: "There was a problem with one of your endpoints, make sure they are in the SF Metro area and try again", status: 422
    end
  end

  private
  def valid_request
    @direction.origin && @direction.destination
  end
end