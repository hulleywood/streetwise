namespace :distance_opt do
  desc "Benchmark nearest intersection calculations"
  task benchmark_nearest_int: :environment do
    tstart_all = Time.now

    lat_min = 37706132
    lat_range = 104102
    lon_min = -122542413
    lon_range = 151989
    mult = 1000000.0

    test_points = []

    2.times do
      rand_lat = (Random.rand(lat_range) + lat_min)/mult
      rand_lon = (Random.rand(lon_range) + lon_min)/mult
      new_point = { "lat" => rand_lat, "lon" => rand_lon }
      test_points << new_point
    end

    nodes = Graph.intersections
    man_closest = []
    hvs_closest = []

    tstart_man = Time.now
    test_points.each do |tp|
      man_closest << Graph.get_nearest_node_man(tp, nodes)
    end
    tend_man = Time.now

    tstart_hvs = Time.now
    test_points.each do |tp|
      hvs_closest << Graph.get_nearest_node_hvs(tp, nodes)
    end
    tend_hvs = Time.now

    man_closest.map! { |n| [n["data"]["osm_node_id"], n["data"]["lat"], n["data"]["lon"]]}
    hvs_closest.map! { |n| [n["data"]["osm_node_id"], n["data"]["lat"], n["data"]["lon"]]}

    closest = man_closest.zip(hvs_closest)
    closest.reject! { |pair| pair.first.first == pair.last.first }

    closest.each do |pair|
      puts "#{pair.first[1]}, #{pair.first[2]}"
      puts "#{pair.last[1]}, #{pair.last[2]}"
    end

    tend_all = Time.now
    puts "Time to complete man: #{tend_man - tstart_man} seconds"
    puts "Time to complete hvs: #{tend_hvs - tstart_hvs} seconds"
    puts "Time to complete all: #{tend_all - tstart_all} seconds"
    puts "Accuracy: #{100 - closest.count}%"
  end

  desc "Benchmark db queries"
  task benchmark_query: :environment do
    tstart = Time.now
      nodes = Graph.intersections
    tend = Time.now
    puts "Total time graph(int): #{tend - tstart}"

    tstart = Time.now
      nodes = Graph.all_nodes
    tend = Time.now
    puts "Total time graph (all): #{tend - tstart}"

    tstart = Time.now
      nodes = Node.all.to_a
    tend = Time.now
    puts "Total time ar: #{tend - tstart}"
  end
end