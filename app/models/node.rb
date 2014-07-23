class Node < ActiveRecord::Base
  has_many :waypoints

  validates :osm_node_id, presence: true
  validates :crime_rating, presence: true
  validates :lat, presence: true
  validates :lon, presence: true

  def self.intersections
    Node.where(intersection: true)
  end

  def self.closest_nodes(args)
    coords = args[:coords]
    distance = args[:distance] || 0.002
    intersection = args[:intersection]

    lat_range = Node.coord_range(coords[:lat], distance)
    lon_range = Node.coord_range(coords[:lon], distance)

    if intersection
      close_nodes = Node.where(lat: lat_range, lon: lon_range, intersection: intersection).to_a
    else
      close_nodes = Node.where(lat: lat_range, lon: lon_range).to_a
    end

    if close_nodes.length > 0
      close_nodes.map! do |node|
        distance_to = Node.distance_between_points(node, coords)
        { node: node, distance: distance_to }
      end

      return close_nodes.sort_by! { |node| node[:distance] }
    else
      return self.close_nodes({ coords: coords, distance: 0.1, intersection: intersection })
    end
  end

  def self.coord_range(coord, distance)
    if coord > 0
      (coord - distance).to_s..(coord + distance).to_s
    else
      (coord - distance).to_s..(coord + distance).to_s
    end
  end

  def self.distance_between_points(point1, point2)
    rad = 3959
    theta1 = self.deg_to_rad(point1[:lat].to_f)
    theta2 = self.deg_to_rad(point2[:lat].to_f)
    lam1 = self.deg_to_rad(point1[:lon].to_f)
    lam2 = self.deg_to_rad(point2[:lon].to_f)

    latDiff = theta2 - theta1
    lonDiff = lam2 - lam1

    x = Math.sin(latDiff/2) ** 2
    y = Math.cos(theta1) * Math.cos(theta2) * Math.sin(lonDiff/2) ** 2
    z = Math.sqrt(x + y)
    hvs = 2 * rad * Math.sinh(z)
  end

  def self.deg_to_rad(deg)
    deg * Math::PI / 180
  end
end