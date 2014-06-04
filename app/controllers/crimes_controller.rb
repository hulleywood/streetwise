class CrimesController < ApplicationController
  def near_crimes
    # take midpoint and radius
    # return crimes "in the box"
    @crimes = Crime.get_near_crimes(params[:midpoint], params[:radius])
  end
end