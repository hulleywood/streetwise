class CrimesController < ApplicationController
  def create
    Crime.create(crime_params)
  end

  private
  def crime_params
    params.require(:crime).permit( :time, :category, :pddistrict, :address, :descript, :dayofweek, :resolution, :date, :y, :x, :incidntnum )
  end
end