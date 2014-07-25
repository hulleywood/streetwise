class DirectionsController < ApplicationController
  def show
    tstart = Time.now
    puts "#{Time.now} Starting request on server..."
    @direction = Direction.new(params)
    puts "#{Time.now} Direction instance created..."

    response = @direction.gen_paths
    if response
      tend = Time.now
      puts "#{Time.now} Response object generated, sending..."
      puts "Total time to complete request: #{tend - tstart}"
      render json: response
    else
      render json: "Something went wrong, please try again", status: 422
    end
  end
end