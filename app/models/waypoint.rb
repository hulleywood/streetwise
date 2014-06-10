class Waypoint < ActiveRecord::Base
  belongs_to :node
  belongs_to :highway
  belongs_to :previous_node, class_name: "Node", foreign_key: "node_id"
  belongs_to :next_node, class_name: "Node", foreign_key: "node_id"

  validates :osm_node_id, presence: true
  validates :osm_highway_id, presence: true

end