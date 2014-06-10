class Node < ActiveRecord::Base
  has_many :waypoints
  has_many :highways, through: :waypoints

  validates :osm_node_id, presence: true
  validates :crime_rating, presence: true
  validates :lat, presence: true
  validates :lon, presence: true

  def self.intersections
    Node.where(intersection: true)
  end
end