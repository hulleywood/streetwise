class Crime < ActiveRecord::Base
  def self.get_near_crimes(midpoint, radius)
    lat_range = Crime.get_lat_range(midpoint, radius)
    lng_range = Crime.get_lng_range(midpoint, radius)
    Crime.where(y: lat_range, x: lng_range)
  end

  def self.get_lat_range(midpoint, radius)
    if midpoint[:lat] > 0
      (midpoint[:lat] - radius).to_s..(midpoint[:lat] + radius).to_s
    else
      (midpoint[:lat] + radius).to_s..(midpoint[:lat] - radius).to_s
    end
  end

  def self.get_lng_range(midpoint, radius)
    if midpoint[:lng] > 0
      (midpoint[:lng] - radius).to_s..(midpoint[:lng] + radius).to_s
    else
      (midpoint[:lng] + radius).to_s..(midpoint[:lng] - radius).to_s
    end
  end

  def self.near_node(node)
    range_constant = 0.0016
    crimes = Crime.all
    crimes.reject! { |crime| distance_between_nodes(node, crime) > range_constant }
  end

  private
  # def crime_params
  #   params.require(:crime).permit( :time, :category, :pddistrict, :address, :descript, :dayofweek, :resolution, :date, :y, :x, :incidntnum )
  # end

  def distance_between_nodes(node, crime)
    squared_lat = (node.lat - crime.y.to_f) ** 2
    squared_lon = (node.lon - crime.x.to_f) ** 2
    Math.sqrt(squared_lat + squared_lon)
  end
end