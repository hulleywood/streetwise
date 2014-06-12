namespace :osm_data_clean do
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
