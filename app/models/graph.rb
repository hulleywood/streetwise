class Graph
  neo4j_url = ENV["GRAPHENEDB_URL"] || "http://localhost:7474"
  @neo = Neography::Rest.new(neo4j_url)
  median_crime_rating = 7.5
  median_distance = 0.00932
  @@coeff = median_distance/median_crime_rating

  def self.get_node(node)
    @neo.get_node(node)
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

  def self.get_paths(ar_node1, ar_node2)
    tstart = Time.now
    node1 = self.find_by_osm_id(ar_node1.osm_node_id)
    node2 = self.find_by_osm_id(ar_node2.osm_node_id)
    max_depth = 10000

    paths = {}
    threads = []
    weights = [ "weight_safest_12", "weight_safest_14",
      "weight_safest_18", "weight_shortest" ]

    puts "#{Time.now - tstart} seconds: starting path generation..."
    weights.each do |weight|
      paths["#{weight}"] = self.get_weighted_path(node1, node2, weight, max_depth, "intersects")
    end

    paths = self.sort_paths_by(weights, paths)

    tend = Time.now
    puts "#{Time.now} Ending path generation..."
    puts "Total time to complete path gen: #{tend-tstart}"

    paths
  end

  def self.return_path_points(path)
    nodes = path["nodes"]
    nodes.map!{ |node_url| @neo.get_node(node_url.split('/').last) }
    points = nodes.map{ |node| [self.get_lat(node), self.get_lon(node)] }
  end

  def self.create_node(node_args)
    @neo.create_node(node_args)
  end

  def self.create_node_indices(n)
    @neo.add_to_index("ar_id_index", "r_id", n["data"]["id"], n)
    @neo.add_to_index("lat_index", "lat", n["data"]["lat"], n)
    @neo.add_to_index("lon_index", "lon", n["data"]["lon"], n)
    @neo.add_to_index("crime_rating_index", "crime_rating", n["data"]["crime_rating"], n)
    @neo.add_to_index("elevation_index", "elevation", n["data"]["elevation"], n)
  end

  def self.all_relationships
    rels = @neo.execute_query("START rels = relationship(*) RETURN rels")["data"]
    rels.map { |rel| rel.first }
  end

  def self.all
    nodes = @neo.execute_query("START nodes = node(*) RETURN nodes")["data"]
    nodes.map { |node| node.first }
  end

  def self.create_intersection_relationship(start_node, end_node, properties)
    rel = @neo.create_relationship("intersects", start_node, end_node)
    properties.each do |k, v|
      @neo.set_relationship_properties(rel, {k => v})
    end
  end

  def self.find_by_osm_id(osm_id)
    @neo.get_node_index("osm_node_id_index", "osm_node_id", osm_id).first
  end

  private
  def self.get_weighted_path(node1, node2, weight, max_depth, rel = "neighbors")
    relationships = {"type" => rel, "direction" => "out"}
    path = @neo.get_shortest_weighted_path(node1, node2, relationships,
                                           weight_attr=weight, depth=max_depth,
                                           algorithm='dijkstra').first

    puts "#{Time.now} Path found, returning points..."
    points = self.return_path_points(path)
    puts "#{Time.now} Points found..."
    points
  end

  def self.get_lat(node)
    node["data"]["lat"].to_f
  end

  def self.get_lon(node)
    node["data"]["lon"].to_f
  end

  def self.print_path(path)
    puts "-" * 80
    path["nodes"].each do |node_url|
      node = @neo.get_node(node_url.split('/').last)
      self.print_node_position(node)
    end
  end

  def self.print_node_position(node)
    puts "#{self.get_lat(node)}, #{self.get_lon(node)}"
  end

  def self.sort_paths_by(weights, paths)
    weights.map { |weight| paths["#{weight}"] }
  end
end
