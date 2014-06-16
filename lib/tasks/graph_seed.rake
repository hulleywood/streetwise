namespace :graph_seed do

  @neo = Neography::Rest.new

  desc 'Migrate nodes from PG to Neo'
  task create_graph_nodes: :environment do
    tstart = Time.now

    # node_args = Node.all.map do |ar_node|
    #   { osm_node_id: ar_node.osm_node_id,
    #     lat: ar_node.lat,
    #     lon: ar_node.lon,
    #     intersection: ar_node.intersection,
    #     crime_rating: ar_node.crime_rating }
    # end

    # @neo.create_nodes_threaded(node_args)

    Node.all.each do |ar_node|
      graph_node = @neo.create_node(
      { osm_node_id: ar_node.osm_node_id,
              lat: ar_node.lat,
              lon: ar_node.lon,
              intersection: ar_node.intersection,
              crime_rating: ar_node.crime_rating })
      @neo.add_to_index("intersection_index", "intersection", ar_node.intersection, graph_node)
      @neo.add_to_index("osm_node_id_index", "osm_node_id", ar_node.osm_node_id, graph_node)
      @neo.add_to_index("ar_node_id_index", "ar_node_id", ar_node.id, graph_node)
    end

    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end

  desc 'Create neighbor relationships'
  task create_neighbor_relationships: :environment do
    tstart = Time.now

    graph_nodes = @neo.execute_query("START nodes = node(*)
                                RETURN nodes")["data"]

    graph_nodes.each do |node_arr|
      graph_node = node_arr.first
      ar_node = Node.find_by_osm_node_id(graph_node["data"]["osm_node_id"])
      waypoints = ar_node.waypoints
      waypoints.each do |wpt|
        make_neighbor_relationship(graph_node, wpt.previous_node) if wpt.previous_node
        make_neighbor_relationship(graph_node, wpt.next_node) if wpt.next_node
      end
    end

    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end

  desc 'Create intersection relationships'
  task create_intersection_relationships: :environment do
    tstart = Time.now



    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end

  desc "Delete at graph nodes"
  task delete_graph_nodes: :environment do

  end

  def make_neighbor_relationship(graph_node, ar_node)
    neighbor_node = @neo.get_node_index("ar_node_id_index", "ar_node_id", ar_node.id).first
    # p neighbor_node
    # p return_graph_id(graph_node)
    rel = @neo.create_relationship("neighbors", graph_node, neighbor_node)
    distance = get_node_distance(graph_node, neighbor_node)
    @neo.set_relationship_properties(rel, {"distance" => distance})
  end

  def return_graph_id(graph_node)
    graph_node["self"].split('/').last.to_i
  end

  def get_node_distance(node1, node2)
    squared_lat = (get_lat(node1) - get_lat(node2)) ** 2.00
    squared_lon = (get_lon(node1) - get_lon(node2)) ** 2.00
    Math.sqrt(squared_lat + squared_lon)
  end

  def get_lat(node)
    node["data"]["lat"].to_f
  end

  def get_lon(node)
    node["data"]["lon"].to_f
  end
end