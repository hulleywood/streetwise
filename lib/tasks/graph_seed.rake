namespace :graph_seed do

  @neo = Neography::Rest.new

  desc 'Migrate nodes from PG to Neo'
  task create_graph_nodes: :environment do
    tstart = Time.now

    Node.all.each do |ar_node|
      graph_node = Graph.create_node(ar_node)
      Graph.create_node_indices(ar_node, graph_node)
    end

    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end

  desc 'Create neighbor relationships'
  task create_neighbor_relationships: :environment do
    tstart = Time.now

    graph_nodes = Graph.all_nodes

    graph_nodes.each do |graph_node|
      ar_node = Node.find_by_osm_node_id(graph_node["data"]["osm_node_id"])
      wpts = ar_node.waypoints
      wpts.each { |wpt| Graph.create_neighbor_relationships(graph_node, ar_node, wpt) }
    end

    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end

  # desc 'Create intersection relationships'
  # task create_intersection_relationships: :environment do
  #   tstart = Time.now

  #   # get each intersection node
  #   intersection_nodes = Graph.intersections
  #   # for each, find every immediate neighbor intersection
  #   # determine distance, crime, total cost
  #   # create relationship

  #   tend = Time.now
  #   puts "Time to complete: #{tend - tstart} seconds"
  # end
end