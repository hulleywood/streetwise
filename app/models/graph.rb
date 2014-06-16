class Graph
  @neo = Neography::Rest.new

  def self.create_node(ar_node)
    node_args = Graph.create_graph_args(ar_node)
    @neo.create_node(node_args)
  end

  def self.create_node_indices(ar_node, graph_node)
    @neo.add_to_index("intersection_index", "intersection", ar_node.intersection, graph_node)
    @neo.add_to_index("osm_node_id_index", "osm_node_id", ar_node.osm_node_id, graph_node)
    @neo.add_to_index("ar_node_id_index", "ar_node_id", ar_node.id, graph_node)
  end

  def self.all
    nodes = @neo.execute_query("START nodes = node(*) RETURN nodes")["data"]
    nodes.map { |node| node.first }
  end

  def self.intersections

  end

  def self.create_neighbor_relationships(graph_node, wpt)
    make_neighbor_relationship(graph_node, wpt.previous_node) if wpt.previous_node
    make_neighbor_relationship(graph_node, wpt.next_node) if wpt.next_node
  end

  def self.create_intersection_relationships(current_int, next_int)
    unless Graph.relationship_exists(current_int, next_int, 'connects')

    end
  end

  private
  def self.make_neighbor_relationship(graph_node, ar_node)
    neighbor_node = @neo.get_node_index("ar_node_id_index", "ar_node_id", ar_node.id).first

    unless Graph.relationship_exists(graph_node, neighbor_node, 'neighbors')
      rel = @neo.create_relationship("neighbors", graph_node, neighbor_node)
      distance = Graph.get_node_distance(graph_node, neighbor_node)
      puts "Distance: #{distance}"
      @neo.set_relationship_properties(rel, {"distance" => distance})
    end
  end

  def self.relationship_exists(n1, n2, rel)
    rels = @neo.get_node_relationships(n1, "all", rel)
    end_nodes = []
    if rels.length > 0
      end_nodes << rels.first["end"].split('/').last
      end_nodes << rels.first["start"].split('/').last
      end_nodes.include?(Graph.get_node_id(n2))
    else
      false
    end
  end

  def self.get_node_id(node)
    node["self"].split('/').last
  end

  def self.create_graph_args(ar_node)
    { osm_node_id: ar_node.osm_node_id,
      lat: ar_node.lat,
      lon: ar_node.lon,
      intersection: ar_node.intersection,
      crime_rating: ar_node.crime_rating }
  end

  def self.get_node_distance(node1, node2)
    squared_lat = (Graph.get_lat(node1) - Graph.get_lat(node2)) ** 2
    puts "Squared lat: #{squared_lat}"
    squared_lon = (Graph.get_lon(node1) - Graph.get_lon(node2)) ** 2
    puts "Squared lon: #{squared_lon}"
    Math.sqrt(squared_lat + squared_lon)
  end

  def self.get_lat(node)
    node["data"]["lat"].to_f
  end

  def self.get_lon(node)
    node["data"]["lon"].to_f
  end
end