class CrimesController < ApplicationController
  def near_crimes
    @crimes = Crime.get_near_crimes(params[:midpoint], params[:radius])
    @crimes.map! { |crime| { k: crime.y.to_i, A: crime.x.to_i } }

    content_type :json
    @crimes.to_json
  end
end