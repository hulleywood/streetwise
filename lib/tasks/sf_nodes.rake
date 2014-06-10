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
    tstart = Time.now
    map_parser = OSMParser.new('lib/tasks/san-francisco.osm')
    map_parser.prepare_parser
    map_parser.parse_nodes
    osm_nodes = map_parser.return_bound_node_hashes

    puts "About to add #{osm_nodes.length} nodes to the database..."
    osm_nodes.each { |node| Node.create(node) }

    # batch_of_threads = []
    # pool_size = 14
    # batch_size = osm_nodes.size/pool_size
    # puts "Adding #{pool_size} batches of #{batch_size} nodes to the database"
    # osm_nodes.each_slice(batch_size) do |slice|
    #   thr = Thread.new(slice) do |node_group|
    #     node_group.each do |node|
    #       Node.create(node)
    #     end
    #     puts "Node group finished"
    #   end
    #   batch_of_threads << thr
    # end

    # batch_of_threads.map(&:join)
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


    # batch_of_threads = []
    # pool_size = 14
    # batch_size = osm_highways.size/pool_size
    # puts "Adding #{pool_size} batches of #{batch_size} highways to the database"
    # osm_highways.each_slice(batch_size) do |slice|
    #   thr = Thread.new(slice) do |highway_group|

    #     highway_group.each do |highway|
    #       new_highway = Highway.create()
    #       highway[:nodes].each_with_index do |osm_node, index|

    #         # Create the waypoint and create assign it to the highway being created
    #         new_waypoint = Waypoint.create( 
    #           { osm_highway_id: highway[:osm_highway_id], osm_node_id: osm_node } )
    #         new_highway.waypoints << new_waypoint

    #         # Find the node instance with the osm id ref from the DB if it exists and add
    #         # relationship between that waypoint and the node
    #         node = Node.find_by_osm_node_id(osm_node)
    #         (node.waypoints << new_waypoint) if node

    #         # Assign next and previous nodes to each waypoint, calling from the highway
    #         # node list using indices
    #         previous_node = highway[:nodes][index - 1] if index > 0
    #         next_node = highway[:nodes][index + 1] if index < (highway[:nodes].length-1)
    #         new_waypoint.update_attribute( :previous_node, previous_node.id ) if previous_node
    #         new_waypoint.update_attribute( :new_node, next_node.id ) if next_node
    #       end
    #       puts "Node group finished"
    #     end
    #   end
    #   batch_of_threads << thr
    # end
    # batch_of_threads.map(&:join)

    tend = Time.now
    puts "Successfully added #{Waypoint.count} waypoints and #{Highway.count} highways to the database!"
    puts "Time to complete: #{tend - tstart} seconds"
  end

  # Run after nodes and waypoints are populated
  # Run before crime stats are calculated or intersections found
  desc 'Remove nodes that do not have a waypoint'
  task remove_non_waypoint_nodes: :environment do
    tstart = Time.now

    batch_of_threads = []
    pool_size = 10
    batch_size = Node.count/pool_size
    puts "Checking #{pool_size} batches of #{batch_size} nodes"

    Node.find_in_batches(batch_size: batch_size) do |batch_of_nodes|
      thr = Thread.new(batch_of_nodes) do |nodes|
        nodes.each do |node|
          node.destroy if node.waypoints.size == 0
        end
        puts "Node group finished"
      end
      batch_of_threads << thr
    end

    batch_of_threads.map(&:join)
    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end

  # Run after nodes and waypoints are populated
  # Run before crime stats are calculated or intersections found  
  desc 'Remove waypoints that have no nodes in SF'
  task remove_waypoints_outside_sf: :environment do
    tstart = Time.now
    batch_of_threads = []
    pool_size = 10
    batch_size = Waypoint.count/pool_size
    puts "Checking #{pool_size} batches of #{batch_size} waypoints"

    Waypoint.find_in_batches(batch_size: batch_size) do |batch_of_waypoints|
      thr = Thread.new(batch_of_waypoints) do |waypoints|
        waypoints.each do |waypoint|
          waypoint.destroy if waypoint.node == nil
        end
        puts "Waypoint group finished"
      end
      batch_of_threads << thr
    end

    batch_of_threads.map(&:join)
    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end

  # Run after nodes and waypoints are and sanitized
  # Run before crime stats are calculated or intersections found
  desc 'Remove highways that have no nodes in SF'
  task remove_highways_outside_sf: :environment do
    tstart = Time.now
    batch_of_threads = []
    pool_size = 10
    batch_size = Highway.count/pool_size
    puts "Checking #{pool_size} batches of #{batch_size} highways"

    Highway.find_in_batches(batch_size: batch_size) do |batch_of_highways|
      thr = Thread.new(batch_of_highways) do |highways|
        highways.each do |highway|
          highway.destroy if highway.waypoints.size == 0
        end
        puts "Highway group finished"
      end
      batch_of_threads << thr
    end

    batch_of_threads.map(&:join)
    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end

  # Run after nodes, waypoints, highways have been created and sanitized
  desc 'Find intersection nodes'
  task find_intersection_nodes: :environment do
    tstart = Time.now
    batch_of_threads = []
    pool_size = 10
    batch_size = Node.count/pool_size
    puts "Checking #{pool_size} batches of #{batch_size} nodes"

    Node.find_in_batches(batch_size: batch_size) do |batch_of_nodes|
      thr = Thread.new(batch_of_nodes) do |nodes|
        nodes.each do |node|
          node.update_attribute( :intersection, true ) if node.waypoints.length > 1
        end
        puts "Node group finished"
      end
      batch_of_threads << thr
    end

    batch_of_threads.map(&:join)
    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end

  # Run after nodes, waypoints, highways have been created and sanitized
  desc 'Calculate crime rating for each node'
  task calculate_node_crime_rating: :environment do  
    tstart = Time.now  
    batch_of_threads = []
    pool_size = 10
    batch_size = Node.count/pool_size
    puts "Checking #{pool_size} batches of #{batch_size} nodes"

    Node.find_in_batches(batch_size: batch_size) do |batch_of_nodes|
      thr = Thread.new(batch_of_nodes) do |nodes|
        nodes.each do |node|
          crimes = Crime.get_near_crimes(node)
          node.update_attribute( :crime_rating, crimes.length )
        end
        puts "Node group finished"
      end
      batch_of_threads << thr
    end

    batch_of_threads.map(&:join)
    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end

  desc 'Print stats'
  task print_stats: :environment do
    puts "Crimes: #{Crime.count}"
    puts "Nodes: #{Node.count}"
    puts "Highways: #{Highway.count}"
    puts "Waypoints: #{Waypoint.count}"
  end
end
