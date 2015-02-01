class Relationship < ActiveRecord::Base
  belongs_to :node
  belongs_to :start_node, class_name: 'Node'
  belongs_to :end_node, class_name: 'Node'

  def self.create_from_csv_args(args)
    start_node = Node.find_by_osm_node_id(args["osm_start_id"])
    end_node = Node.find_by_osm_node_id(args["osm_end_id"])
    args.delete('osm_start_id')
    args.delete('osm_end_id')

    rel = self.create(args)
    rel.start_node = start_node if start_node
    rel.end_node = end_node if end_node
    start_node.relationships << rel
    end_node.relationships << rel

    start_node.save
    end_node.save
    rel.save
  end

  def self.create_neighbors(node, wpt)
    make_neighbor_relationship(node, wpt.previous_node) if wpt.previous_node
    make_neighbor_relationship(node, wpt.next_node) if wpt.next_node
  end

  def self.make_neighbor_relationship(node, neighbor)
    unless relationship_exists(node, neighbor, 'neighbors')
      rel = self.new(start_node: node, end_node: neighbor)
      rel.intersectional = node.intersection? && neighbor.intersection?
      rel.populate_distance
      rel.populate_crime_rating
      rel.populate_gradient
      rel.set_relationship_weights

      @neo.set_relationship_properties(rel, {"distance" => distance, "crime_rating" => crime_rating})
      updated_rel = @neo.get_relationship(rel)
      Graph.update_relationship_weights(updated_rel)
    end
  end

  def self.relationship_exists(n1, n2)
    rel = Relationship.find(start_node: n1, end_node: n2)
    rel ||= Relationship.find(start_node: n2, end_node: n1)
    !!rel
  end

  def populate_distance
    rel.distance = calc_node_distance
    rel.normalized_distance = ENV['distance_coefficient'] * rel.distance
  end

  def populate_crime_rating
    rel.crime_rating = calc_crime_rating
    rel.normalized_crime_rating = ENV['crime_rating_coefficient'] * rel.crime_rating
  end

  def populate_gradient
    rel.gradient = calc_node_gradient
    rel.normalized_gradient = ENV['gradient_coefficient'] * rel.gradient
  end

  def set_relationship_wieghts
  end

  def calc_node_distance
    conv_node1 = { 'lat' => self.start_node.lat, 'lon' => start_node.lon }
    conv_node2 = { 'lat' => self.end_node.lat, 'lon' => end_node.lon }
    Node.point_distance_hvs(conv_node1, conv_node2)
  end

  def calc_crime_rating
    (node1.crime_rating + node2.crime_rating)/2
  end
end
