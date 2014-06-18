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

  def self.close_nodes(coords, distance = 0.0016)
    lat_range = Node.coord_range(coords[:lat], distance)
    lon_range = Node.coord_range(coords[:lon], distance)
    close_nodes = Node.where(lat: lat_range, lon: lon_range).to_a
    close_nodes.map! do |node|
      distance_to = Node.distance_between_points(node, coords)
      { node: node, distance: distance_to }
    end
    close_nodes.sort_by { |node| node[:distance] }
  end

  def self.coord_range(coord, distance)
    if coord > 0
      (coord - distance).to_s..(coord + distance).to_s
    else
      (coord - distance).to_s..(coord + distance).to_s
    end
  end
end