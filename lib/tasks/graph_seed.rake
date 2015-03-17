namespace :graph_seed do

  @neo = Neography::Rest.new

  desc 'Migrate nodes from PG to Neo'
  task create_graph_nodes_from_pg: :environment do
    tstart = Time.now

    Node.where(intersection: true).each do |ar_node|
      graph_node = Graph.create_node(ar_node.attributes)
      Graph.create_node_indices(graph_node)
    end

    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end

  desc "Add node labels to graph DB"
  task create_node_labels: :environment do
    tstart = Time.now
    nodes = Graph.all

    nodes.each do |node|
      Graph.add_label(node, "intersection")
      Graph.add_label(node, "street_node")
    end

    puts nodes.length
    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end

  desc "Write intersection relationships to csv"
  task write_intersects_rel_csv: :environment do
    tstart = Time.now
    rels = Graph.all_relationships
    rels.reject! {|r| r["type"] != "intersects"}

    data = rels.map do |r|
      start_id = Graph.get_node(r["start"])["data"]["osm_node_id"]
      end_id = Graph.get_node(r["end"])["data"]["osm_node_id"]

      [ r["data"]["crime_rating"].round(5),
        r["data"]["distance"].round(5),
        r["data"]["weight_safest_12"].round(5),
        r["data"]["weight_safest_14"].round(5),
        r["data"]["weight_safest_18"].round(5),
        r["data"]["weight_shortest"].round(5),
        start_id,
        end_id ]
    end

    Dir.chdir('./lib/assets')
    file = File.join( Dir.pwd, '/graph_intersects_rels.csv')
    headers = [ 'crime_rating',
                'distance',
                "weight_safest_12",
                "weight_safest_14",
                "weight_safest_18",
                "weight_shortest",
                "osm_start_id",
                "osm_end_id" ]

    CSV.open(file, 'w+') do |csv|
      csv << headers
      data.each { |d| csv << d }
    end

    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end

  desc "Write intersection nodes to csv"
  task write_intersects_nodes_csv: :environment do
    tstart = Time.now
    nodes = Graph.intersections

    data = nodes.map do |n|
    [
      n["data"]["osm_node_id"],
      n["data"]["lat"],
      n["data"]["lon"],
      n["data"]["intersection"],
      n["data"]["crime_rating"]
      ]
    end

    Dir.chdir('./lib/assets')
    file = File.join( Dir.pwd, '/graph_intersects_nodes.csv')
    headers = [ "osm_node_id",
                "lat",
                "lon",
                "intersection",
                "crime_rating" ]

    CSV.open(file, 'w+') do |csv|
      csv << headers
      data.each { |d| csv << d }
    end

    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end

  desc "Create graph nodes from csv"
  task create_nodes_from_csv: :environment do
    tstart = Time.now
    Dir.chdir('./lib/assets')
    file = File.join( Dir.pwd, '/graph_intersects_nodes.csv')

    csv_data = CSV.read(file)
    headers = csv_data.shift

    string_data = csv_data.map {|row| row.map {|cell| cell.to_s } }
    array_of_hashes = string_data.map {|row| Hash[*headers.zip(row).flatten] }

    array_of_hashes.each do |args|
      graph_node = Graph.create_node(args)
      Graph.create_node_indices(graph_node)
    end

    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end

  desc "Create graph relationships from csv"
  task create_relationships_from_csv: :environment do
    tstart = Time.now
    Dir.chdir('./lib/assets')
    file = File.join( Dir.pwd, '/graph_intersects_rels.csv')

    csv_data = CSV.read(file)
    headers = csv_data.shift

    string_data = csv_data.map {|row| row.map {|cell| cell.to_s } }
    array_of_hashes = string_data.map {|row| Hash[*headers.zip(row).flatten] }

    array_of_hashes.each do |args|
      start_node = Graph.find_by_osm_id(args["osm_start_id"])
      end_node = Graph.find_by_osm_id(args["osm_end_id"])
      rel = Graph.create_intersection_relationship(start_node, end_node, args)
    end

    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end
end
