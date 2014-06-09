class Crime < ActiveRecord::Base
  validates :x, presence: true
  validates :y, presence: true
  validates :date, presence: true

  def self.get_near_crimes(node, radius = 0.0016)
    lat_range = Crime.get_lat_range(node, radius)
    lon_range = Crime.get_lon_range(node, radius)
    Crime.where(y: lat_range, x: lon_range)
  end

  def self.get_lat_range(node, radius)
    if node.lat > 0
      (node.lat - radius).to_s..(node.lat + radius).to_s
    else
      (node.lat + radius).to_s..(node.lat - radius).to_s
    end
  end

  def self.get_lon_range(node, radius)
    if node.lon > 0
      (node.lon - radius).to_s..(node.lon + radius).to_s
    else
      (node.lon + radius).to_s..(node.lon - radius).to_s
    end
  end

  private
  # def crime_params
  #   params.require(:crime).permit( :time, :category, :pddistrict, :address, :descript, :dayofweek, :resolution, :date, :y, :x, :incidntnum )
  # end

  # def self.distance_between_nodes(node, crime)
  #   squared_lat = (node.lat - crime.y.to_f) ** 2
  #   squared_lon = (node.lon - crime.x.to_f) ** 2
  #   Math.sqrt(squared_lat + squared_lon)
  # end
end