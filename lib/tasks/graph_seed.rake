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

  desc "Create intersection relationships"
  task create_intersects_relationships: :environment do
    tstart = Time.now
    ints = Graph.intersections
    new_rels = 0

    properties = [  "weight_safest_12", "weight_safest_14",
                    "weight_safest_18", "weight_shortest",
                    "distance", "crime_rating" ]

    ints.each do |int|
      int_paths = Graph.traverse_next_ints(int)
      int_paths.each do |path|
        values = {}
        properties.each do |prop|
          values[prop] = Graph.sum_property(path, prop)
        end
        Graph.create_intersection_relationship(int, path["end"], values)
        new_rels += 1
        puts "Relationship added, total: #{new_rels}"
      end
    end

    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end

  desc "Add node labels to graph DB"
  task create_node_labels: :environment do
    tstart = Time.now
    nodes = Graph.all_nodes

    nodes.each do |node|
      Graph.delete_label(node, "regular_node")

      if node["data"]["intersection"]
        Graph.add_label(node, "intersection")
      else
        Graph.add_label(node, "regular_node")
      end

      Graph.add_label(node, "street_node")
    end

    puts nodes.length
    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end

  desc "Remove neighbor relationships"
  task delete_neighbor_relationships: :environment do
    tstart = Time.now
    rels = Graph.all_relationships

    rels.each do |rel|
      if rel["type"] == "neighbors"
        Graph.delete_relationship(rel)
      end
    end

    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end

  desc "Remove non intersection nodes"
  task delete_non_intersection_nodes: :environment do
    tstart = Time.now
    nodes = Graph.all_nodes

    nodes.each do |node|
      if !node["data"]["intersection"]
        Graph.delete_node(node)
      end
    end

    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end
end