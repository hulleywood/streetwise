namespace :osm_data_creation do
  # Run first if no nodes exist
  desc 'Parse OSM file for nodes inside SF limits and add to DB'
  task create_sf_nodes: :environment do
    tstart = Time.now
    map_parser = OSMParser.new('lib/tasks/san-francisco.osm')
    map_parser.prepare_parser
    map_parser.parse_nodes
    osm_nodes = map_parser.return_bound_node_hashes

    puts "About to add #{osm_nodes.length} nodes to the database..."
    osm_nodes.each { |node| Node.create(node) }

    tend = Time.now
    puts "Successfully added #{Node.count} nodes to the database!"
    puts "Time to complete: #{tend - tstart} seconds"
  end

  # Run second, must be ran after nodes are populated
  desc 'Parse OSM file for ways, create waypoints'
  task create_waypoints: :environment do
    tstart = Time.now
    map_parser = OSMParser.new('lib/tasks/san-francisco.osm')
    map_parser.prepare_parser
    map_parser.parse_highways
    osm_highways = map_parser.return_highways

    osm_highways.each do |highway|
      highway[:nodes].each_with_index do |osm_node, index|

        new_waypoint = Waypoint.create( { osm_node_id: osm_node } )

        node = Node.find_by_osm_node_id(osm_node)
        (node.waypoints << new_waypoint) if node

        previous_osm_node = highway[:nodes][index - 1] if index > 0
        if previous_osm_node
          previous_node = Node.find_by_osm_node_id(previous_osm_node)
          new_waypoint.previous_node = previous_node if previous_node
        end

        next_osm_node = highway[:nodes][index + 1] if index < (highway[:nodes].length-1)
        if next_osm_node
          next_node = Node.find_by_osm_node_id(next_osm_node)
          new_waypoint.next_node = next_node if next_node
        end

        new_waypoint.save
      end
    end

    tend = Time.now
    puts "Successfully added #{Waypoint.count} waypoints to the database!"
    puts "Time to complete: #{tend - tstart} seconds"
  end
end