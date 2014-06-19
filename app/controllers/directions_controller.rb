class DirectionsController < ApplicationController
  def show
    @direction = Direction.new(params)
    if valid_request
      response = @direction.gen_paths
      if safe_route
        render json: response
      else
        render json: "Something went wrong, please try again", status: 422
      end
    else
      render json: "There was a problem with one of your endpoints, make sure they are in the SF Metro area and try again", status: 422
    end
  end

  private
  def valid_request
    @direction.origin_node && @direction.destination_node
  end
end