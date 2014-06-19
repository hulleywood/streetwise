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
    puts "Creating relationships for #{graph_nodes.length} nodes"

    graph_nodes.each do |graph_node|
      ar_node = Node.find_by_osm_node_id(graph_node["data"]["osm_node_id"])
      wpts = ar_node.waypoints
      wpts.each { |wpt| Graph.create_neighbor_relationships(graph_node, ar_node, wpt) }
    end

    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end

  desc 'Update neighbor weighting'
  task update_neighbor_weighting: :environment do
    tstart = Time.now

    graph_rels = Graph.all_relationships
    puts "Updating weights for #{graph_rels.length} relationships"

    graph_rels.each do |rel|
      Graph.update_relationship_weights(rel)
    end

    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end

  desc 'Clear relationship weights'
  task clear_relationship_weights: :environment do
    tstart = Time.now

    graph_rels = Graph.all_relationships
    puts "Clearing weights for #{graph_rels.length} relationships"

    graph_rels.each do |rel|
      Graph.clear_relationship_weights(rel)
    end

    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end
end