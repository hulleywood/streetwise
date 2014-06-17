class Graph
  @neo = Neography::Rest.new

  def self.shortest_path(ar_node1, ar_node2, relationship_name, depth=Node.count)
    puts "#{ar_node1.lat}, #{ar_node1.lon}"
    puts "#{ar_node2.lat}, #{ar_node2.lon}"
    relationships = {"type" => relationship_name, "direction" => "all"}
    node1 = Graph.find_by_ar_id(ar_node1.id)
    node2 = Graph.find_by_ar_id(ar_node2.id)
    # @neo.get_path(node1, node2, relationships, depth=depth, algorithm="shortestPath")
    @neo.get_shortest_weighted_path(node1, node2, relationships,
                                weight_attr='distance', depth=depth,
                                algorithm='dijkstra')
  end

  def self.get_distance_info
    rels = Graph.all_relationships
    p rels.length
  end

  def self.create_node(ar_node)
    node_args = Graph.create_graph_args(ar_node)
    @neo.create_node(node_args)
  end

  def self.create_node_indices(ar_node, graph_node)
    @neo.add_to_index("intersection_index", "intersection", ar_node.intersection, graph_node)
    @neo.add_to_index("osm_node_id_index", "osm_node_id", ar_node.osm_node_id, graph_node)
    @neo.add_to_index("ar_node_id_index", "ar_node_id", ar_node.id, graph_node)
  end

  def self.all_relationships
    rels = @neo.execute_query("START rels = relationship(*) RETURN rels")["data"]
    rels.map { |rel| rel.first }
  end

  def self.all_nodes
    nodes = @neo.execute_query("START nodes = node(*) RETURN nodes")["data"]
    nodes.map { |node| node.first }
  end

  def self.create_neighbor_relationships(graph_node, ar_node, wpt)
    make_neighbor_relationship(graph_node, ar_node, wpt.previous_node) if wpt.previous_node
    make_neighbor_relationship(graph_node, ar_node, wpt.next_node) if wpt.next_node
  end

  def self.find_by_ar_id(ar_id)
    @neo.get_node_index("ar_node_id_index", "ar_node_id", ar_id).first
  end

  private
  def self.make_neighbor_relationship(graph_node, ar_node, neighbor_ar)
    neighbor_node = Graph.find_by_ar_id(neighbor_ar.id)

    unless Graph.relationship_exists(graph_node, neighbor_node, 'neighbors')
      rel = @neo.create_relationship("neighbors", graph_node, neighbor_node)
      distance = Graph.get_node_distance(graph_node, neighbor_node)
      crime_rating = Graph.get_crime_rating(ar_node, neighbor_ar)
      @neo.set_relationship_properties(rel, {"distance" => distance, "crime_rating" => crime_rating})
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
    squared_lon = (Graph.get_lon(node1) - Graph.get_lon(node2)) ** 2
    Math.sqrt(squared_lat + squared_lon)
  end

  def self.get_lat(node)
    node["data"]["lat"].to_f
  end

  def self.get_lon(node)
    node["data"]["lon"].to_f
  end

  def self.get_crime_rating(node1, node2)
    (node1.crime_rating + node2.crime_rating)/2
  end
end