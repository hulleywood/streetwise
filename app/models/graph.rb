class Graph
  neo4j_url = ENV["GRAPHENEDB_URL"] || "http://localhost:7474"
  @neo = Neography::Rest.new(neo4j_url)
  median_crime_rating = 7.5
  median_distance = 0.00932
  @@coeff = median_distance/median_crime_rating

  def self.traverse_next_ints(int)
    int_paths = @neo.traverse(int, "paths",
                      {"order" => "depth first",
                       "uniqueness" => "node global",
                       "relationships" => [{"type"=> "neighbors", "direction" => "all"}],
                       "prune evaluator" => {"language" => "javascript",
                        "body" => "(position.endNode().getProperty('intersection') == true) && (position.length() > 0)"}
                       })

    int_paths.reject do |path|
      @neo.get_node(path["end"])["data"]["intersection"] == false
    end
  end

  def self.sum_property(path, weight)
    rels = path["relationships"]
    rels.map! { |r| @neo.get_relationship(r) }
    sum = 0
    rels.each { |r| sum += r["data"][weight] }
    sum
  end

  def self.intersections
    @neo.get_nodes_labeled("intersection")
  end

  def self.add_label(node, label)
    @neo.add_label(node, label)
  end

  def self.delete_label(node, label)
    @neo.delete_label(node, label)
  end

  def self.delete_node(node)
    @neo.delete_node!(node)
  end

  def self.delete_relationship(relationship)
    @neo.delete_relationship(relationship)
  end

  def self.get_paths(ar_node1, ar_node2)
    puts "#{Time.now} Finding nodes in graph db..."
    tstart = Time.now

    node1 = Graph.find_by_ar_id(ar_node1.id)
    node2 = Graph.find_by_ar_id(ar_node2.id)
    max_depth = Node.count

    puts "#{Time.now} Nodes found..."

    paths = {}
    threads = []
    weights = [ "weight_safest_12", "weight_safest_14",
                "weight_safest_18", "weight_shortest" ]

    puts "#{Time.now} Starting path generation..."
    weights.each do |weight|
      paths["#{weight}"] = Graph.get_weighted_path(node1, node2, weight, max_depth, "intersects")
    end

    paths = Graph.sort_paths_by(weights, paths)

    tend = Time.now
    puts "#{Time.now} Ending path generation..."
    puts "Total time to complete path gen: #{tend-tstart}"

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

  def self.update_relationship_weights(rel)
    weight_safest_12 = rel["data"]["distance"] + @@coeff * rel["data"]["crime_rating"]
    weight_safest_14 = rel["data"]["distance"] + @@coeff * rel["data"]["crime_rating"] / 3
    weight_safest_18 = rel["data"]["distance"] + @@coeff * rel["data"]["crime_rating"] / 7
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
    @neo.add_to_index("lat_index", "lat", ar_node.lat, graph_node)
    @neo.add_to_index("lon_index", "lon", ar_node.lon, graph_node)
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

  def self.create_intersection_relationship(start_node, end_node, properties)
    rel = @neo.create_relationship("intersects", start_node, end_node)
    properties.each do |k, v|
      @neo.set_relationship_properties(rel, {k => v})
    end
  end

  def self.find_by_ar_id(ar_id)
    @neo.get_node_index("ar_node_id_index", "ar_node_id", ar_id).first
  end

  def self.distance_from_relationship(rel)
    node1 = rel["start"]
    node2 = rel["end"]

    Graph.calc_node_distance(node1, node2)
  end

  private
  def self.get_weighted_path(node1, node2, weight, max_depth, rel = "neighbors")
    relationships = {"type" => rel, "direction" => "out"}
    path = @neo.get_shortest_weighted_path(node1, node2, relationships,
                                weight_attr=weight, depth=max_depth,
                                algorithm='dijkstra').first

    puts "#{Time.now} Path found, returning points..."
    points = Graph.return_path_points(path)
    puts "#{Time.now} Points found..."
    points
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
    node1 = @neo.get_node(node1)
    node2 = @neo.get_node(node2)
    conv_node1 = { lat: Graph.get_lat(node1), lon: Graph.get_lon(node1) }
    conv_node2 = { lat: Graph.get_lat(node2), lon: Graph.get_lon(node2) }

    Node.distance_between_points(conv_node1, conv_node2)
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

  def self.sort_paths_by(weights, paths)
    weights.map { |weight| paths["#{weight}"] }
  end
end