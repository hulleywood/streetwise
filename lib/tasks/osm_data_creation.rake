namespace :osm_data_creation do
  # Ideal order in which tasks are run:
  # rake osm_tasks:create_sf_nodes
  # rake osm_tasks:create_waypoints_and_highways
  # rake osm_tasks:remove_non_waypoint_nodes
  # rake osm_tasks:remove_waypoints_outside_sf
  # rake osm_tasks:remove_highways_outside_sf
  # rake osm_tasks:find_intersection_nodes
  # rake osm_tasks:calculate_node_crime_rating

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
  desc 'Parse OSM file for ways, add to highway table and create waypoints'
  task create_waypoints_and_highways: :environment do
    map_parser = OSMParser.new('lib/tasks/san-francisco.osm')
    map_parser.prepare_parser
    map_parser.parse_highways
    osm_highways = map_parser.return_highways

    puts "About to add #{osm_highways.length} highways to the databse"

    osm_highways.each do |highway|
      new_highway = Highway.create()
      highway[:nodes].each_with_index do |osm_node, index|

        # Create the waypoint and create assign it to the highway being created
        new_waypoint = Waypoint.create( 
          { osm_highway_id: highway[:osm_highway_id], osm_node_id: osm_node } )
        new_highway.waypoints << new_waypoint

        # Find the node instance with the osm id ref from the DB if it exists and add
        # relationship between that waypoint and the node
        node = Node.find_by_osm_node_id(osm_node)
        (node.waypoints << new_waypoint) if node

        # Assign next and previous nodes to each waypoint, calling from the highway
        # node list using indices
        previous_osm_node = highway[:nodes][index - 1] if index > 0
        if previous_osm_node
          previous_node = Node.find_by_osm_node_id(previous_osm_node)
          new_waypoint.previous_node = previous_node
        end

        next_osm_node = highway[:nodes][index + 1] if index < (highway[:nodes].length-1)
        if next_osm_node
          next_node = Node.find_by_osm_node_id(next_osm_node)
          new_waypoint.next_node = next_node
        end
      end
    end

    tend = Time.now
    puts "Successfully added #{Waypoint.count} waypoints and #{Highway.count} highways to the database!"
    puts "Time to complete: #{tend - tstart} seconds"
  end
end