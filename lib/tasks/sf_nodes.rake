namespace :sf_nodes do
  desc 'Parse OSM file and put into DB nodes inside city limits'
  task create_nodes: :environment do
    map_parser = OSMParser.new('lib/tasks/san-francisco.osm')
    map_parser.parse
    nodes = map_parser.return_bound_node_hashes

    puts "About to add #{nodes.length} nodes to the database..."
    nodes.each { |node| Node.create(node) }
    puts "Successfully added #{Node.count} nodes to the database!"
  end

  desc 'Parse OSM file and create highway/node relationships in database'
  task create_waypoints: :environment do
    map_parser = OSMParser.new('lib/tasks/san-francisco.osm')
    map_parser.parse
    highways = map_parser.return_highways
    puts "About to add A LOT of data..."

    # highway = highways.first
    # highway[:nodes].each do |node_ref|
      # p node_ref
      # waypoint_args = { way_ref: highway[:way_ref],node_ref: node_ref }
      # p waypoint_args
      # Waypoint.create( waypoint_args )
    # end

    highways.each do |highway|
      highway[:nodes].each do |node_ref|
        Waypoint.create( { way_ref: highway[:way_ref], node_ref: node_ref } )
      end
    end
    
    puts "Successfully added #{Waypoint.count} waypoints to the database!"
  end
end
