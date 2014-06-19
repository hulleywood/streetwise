class Graph
  neo4j_url = ENV["GRAPHENEDB_URL"] || "http://localhost:7474"
  # uri = URI.parse(neo4j_url)
  @neo = Neography::Rest.new(neo4j_url)

  def self.get_paths(ar_node1, ar_node2)
    node1 = Graph.find_by_ar_id(ar_node1.id)
    node2 = Graph.find_by_ar_id(ar_node2.id)

    paths = []
    weights = [ "weight_safest_12", "weight_safest_14",
                "weight_safest_18", "weight_shortest" ]

    weights.each do |weight|
      paths << Graph.get_weighted_path(node1, node2, weight)
    end

    paths
  end

  def self.clear_relationship_weights(rel)
    props = @neo.get_relationship_properties(rel)
    distance = props["distance"]
    crime_rating = props["crime_rating"]

    @neo.remove_relationship_properties(rel)
    @neo.set_relationship_properties(rel, {"distance" => distance, "crime_rating" => crime_rating})
  end

  def self.return_path_points(path)
    nodes = path["nodes"]
    nodes.map!{ |node_url| @neo.get_node(node_url.split('/').last) }
    points = nodes.map{ |node| [Graph.get_lat(node), Graph.get_lon(node)] }
  end

  def self.update_relationship_weights(rel, coeff = 4.4011318e-05)
    weight_safest_12 = rel["data"]["distance"] + coeff * rel["data"]["crime_rating"]
    weight_safest_14 = rel["data"]["distance"] + coeff * rel["data"]["crime_rating"] / 3
    weight_safest_18 = rel["data"]["distance"] + coeff * rel["data"]["crime_rating"] / 7
    weight_shortest = rel["data"]["distance"]
    @neo.set_relationship_properties(rel, {"weight_safest_12" => weight_safest_12})
    @neo.set_relationship_properties(rel, {"weight_safest_14" => weight_safest_14})
    @neo.set_relationship_properties(rel, {"weight_safest_18" => weight_safest_18})
    @neo.set_relationship_properties(rel, {"weight_shortest" => weight_shortest})
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
  def self.get_weighted_path(node1, node2, weight)
    relationships = {"type" => 'neighbors', "direction" => "out"}
    max_depth = Node.count
    path = @neo.get_shortest_weighted_path(node1, node2, relationships,
                                weight_attr=weight, depth=max_depth,
                                algorithm='dijkstra').first
    Graph.return_path_points(path)
  end

  def self.make_neighbor_relationship(graph_node, ar_node, neighbor_ar)
    neighbor_node = Graph.find_by_ar_id(neighbor_ar.id)

    unless Graph.relationship_exists(graph_node, neighbor_node, 'neighbors')
      rel = @neo.create_relationship("neighbors", graph_node, neighbor_node)
      distance = Graph.calc_node_distance(graph_node, neighbor_node)
      crime_rating = Graph.calc_crime_rating(ar_node, neighbor_ar)
      @neo.set_relationship_properties(rel, {"distance" => distance, "crime_rating" => crime_rating})
      updated_rel = @neo.get_relationship(rel)
      Graph.update_relationship_weights(updated_rel)
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

  def self.calc_node_distance(node1, node2)
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

  def self.calc_crime_rating(node1, node2)
    (node1.crime_rating + node2.crime_rating)/2
  end

  def self.print_path(path)
    puts "-" * 80
    path["nodes"].each do |node_url|
      node = @neo.get_node(node_url.split('/').last)
      Graph.print_node_position(node)
    end
  end

  def self.print_node_position(node)
    puts "#{Graph.get_lat(node)}, #{Graph.get_lon(node)}"
  end
end