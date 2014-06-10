class CreateWaypoints < ActiveRecord::Migration
  def change
    create_table :waypoints do |t|
      t.string :osm_node_id
      t.string :osm_highway_id
      t.belongs_to :previous_node, class_name: "Node", foreign_key: "node_id"
      t.belongs_to :next_node, class_name: "Node", foreign_key: "node_id"
      t.belongs_to :highway
      t.belongs_to :node
      t.timestamps
    end
  end
end
