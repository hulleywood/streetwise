class Node < ActiveRecord::Base
  has_many :waypoints

  validates :osm_node_id, presence: true
  validates :crime_rating, presence: true
  validates :lat, presence: true
  validates :lon, presence: true

  def self.intersections
    Node.where(intersection: true)
  end

  def self.distance_between_points(point1, point2)
    squared_lat = (point1[:lat] - point2[:lat]) ** 2
    squared_lon = (point1[:lon] - point2[:lon]) ** 2
    Math.sqrt(squared_lat + squared_lon)
  end
end