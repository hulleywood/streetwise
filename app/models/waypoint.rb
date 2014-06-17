class Waypoint < ActiveRecord::Base
  belongs_to :node
  belongs_to :previous_node, class_name: "Node"
  belongs_to :next_node, class_name: "Node"

  validates :osm_node_id, presence: true
end