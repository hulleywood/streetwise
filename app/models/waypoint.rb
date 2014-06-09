class Waypoint < ActiveRecord::Base
  belongs_to :node
  belongs_to :highway

  validates :osm_node_id, presence: true
  validates :osm_highway_id, presence: true

end