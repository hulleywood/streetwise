class Relationship < ActiveRecord::Base
  belongs_to :start_node, class_name: 'Node'
  belongs_to :end_node, class_name: 'Node'

  def self.create_from_csv_args(args)
    start_node = Node.find_by_osm_node_id(args["osm_start_id"])
    end_node = Node.find_by_osm_node_id(args["osm_end_id"])
    args["start_node"] = start_node
    args["end_node"] = end_node
    args.delete('osm_start_id')
    args.delete('osm_end_id')
    rel = self.create(args)
  end
end