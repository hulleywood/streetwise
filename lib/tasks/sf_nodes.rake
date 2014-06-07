namespace :osm_tasks do

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
    map_parser = OSMParser.new('lib/tasks/san-francisco.osm')
    map_parser.prepare_parser
    map_parser.parse_nodes
    nodes = map_parser.return_bound_node_hashes

    puts "About to add #{nodes.length} nodes to the database..."
    nodes.each { |node| Node.create(node) }
    puts "Successfully added #{Node.count} nodes to the database!"
  end

  # Run second, must be ran after nodes are populated
  desc 'Parse OSM file for ways, add to highway table and create waypoints'
  task create_waypoints_and_highways: :environment do
    map_parser = OSMParser.new('lib/tasks/san-francisco.osm')
    map_parser.prepare_parser
    map_parser.parse_highways
    highways = map_parser.return_highways

    puts "About to add #{highways.length} highways to the databse"

    highways.each do |highway|
      new_highway = Highway.create()
      highway[:nodes].each do |osm_node|
        new_waypoint = Waypoint.create( 
          { osm_highway_id: highway[:osm_highway_id], osm_node_id: osm_node } )
        new_highway.waypoints << new_waypoint
        node = Node.find_by_osm_node_id(osm_node)
        (node.waypoints << new_waypoint) if node
      end
    end

    puts "Successfully added #{Waypoint.count} waypoints and #{Highway.count} highways to the database!"
  end

  # Run after nodes and waypoints are populated
  # Run before crime stats are calculated or intersections found
  desc 'Remove nodes that do not have a waypoint'
  task remove_non_waypoint_nodes: :environment do
    nodes = Node.all
    nodes.each do |node|
      puts "Checking node: #{node.id}"
      node.destroy if node.waypoints.size == 0
    end
  end

  # Run after nodes and waypoints are populated
  # Run before crime stats are calculated or intersections found  
  desc 'Remove waypoints that have no nodes in SF'
  task remove_waypoints_outside_sf: :environment do
    waypoints = Waypoint.all
    waypoints.each do |waypoint|
      puts "Checking waypoint: #{waypoint.id}"
      waypoint.destroy if waypoint.node == nil
    end
  end

  # Run after nodes and waypoints are and sanitized
  # Run before crime stats are calculated or intersections found
  desc 'Remove highways that have no nodes in SF'
  task remove_highways_outside_sf: :environment do
    highways = Highway.all
    highways.each do |highway|
      puts "Checking highway: #{highway.id}"
      highway.destroy if highway.waypoints.size == 0
    end
  end

  # Run after nodes, waypoints, highways have been created and sanitized
  desc 'Find intersection nodes'
  task find_intersection_nodes: :environment do
    nodes = Node.all
    nodes.each do |node|
      puts "Checking node: #{node.id}"
      if node.waypoints.length > 1
        node.update_attribute( :intersection, true )
      else
        node.update_attribute( :intersection, false )
      end
    end
  end

  # Run after nodes, waypoints, highways have been created and sanitized
  desc 'Calculate crime rating for each node'
  task calculate_node_crime_rating: :environment do
    nodes = Node.all
    nodes.each do |node|
      crimes = Crime.near_node(node)
      node.update_attribute( :crime_rating, crimes.length )
    end
  end

  desc 'Print stats'
  task print_stats: :environment do
    puts "Crimes: #{Crime.count}"
    puts "Nodes: #{Node.count}"
    puts "Highways: #{Highway.count}"
    puts "Waypoints: #{Waypoint.count}"
  end
end
