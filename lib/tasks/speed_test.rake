namespace :distance_opt do
  desc "Benchmark nearest intersection calculations"
  task benchmark_nearest_int: :environment do
    tstart_all = Time.now

    lat_min = 37750000
    lat_range = 50000
    lon_min = -122500000
    lon_range = 100000
    mult = 1000000.0

    test_points = []

    10.times do
      rand_lat = (Random.rand(lat_range) + lat_min)/mult
      rand_lon = (Random.rand(lon_range) + lon_min)/mult
      new_point = { "lat" => rand_lat, "lon" => rand_lon }
      test_points << new_point
    end

    man_closest = []
    hvs_closest = []
    man_ar_closest = []
    hvs_ar_closest = []
    ar_mix_closest = []

    tstart_man = Time.now
    test_points.each do |tp|
      man_closest << Graph.get_nearest_node_man(tp)
    end
    tend_man = Time.now

    tstart_hvs = Time.now
    test_points.each do |tp|
      hvs_closest << Graph.get_nearest_node_hvs(tp)
    end
    tend_hvs = Time.now

    tstart_man_ar = Time.now
    test_points.each do |tp|
      man_ar_closest << Node.get_nearest_node_man(tp)
    end
    tend_man_ar = Time.now

    tstart_hvs_ar = Time.now
    test_points.each do |tp|
      hvs_ar_closest << Node.get_nearest_node_hvs(tp)
    end
    tend_hvs_ar = Time.now

    tstart_ar_mix = Time.now
    test_points.each do |tp|
      ar_mix_closest << Node.closest_node({ coords: tp, intersection: true })
    end
    tend_ar_mix = Time.now

    man_closest.map! { |n| [n["data"]["osm_node_id"], n["data"]["lat"], n["data"]["lon"]]}
    hvs_closest.map! { |n| [n["data"]["osm_node_id"], n["data"]["lat"], n["data"]["lon"]]}
    man_ar_closest.map! { |n| [n["osm_node_id"], n["lat"], n["lon"]]}
    hvs_ar_closest.map! { |n| [n["osm_node_id"], n["lat"], n["lon"]]}
    ar_mix_closest.map! { |n| [n["osm_node_id"], n["lat"], n["lon"]]}

    closest = man_closest.zip(hvs_closest, man_ar_closest, hvs_ar_closest, ar_mix_closest)
    closest.reject! { |pair| pair.first.first == pair.last.first }

    closest.each do |pair|
      pair.each do |p|
        puts "#{p[1]}, #{p[2]}"
      end
    end

    tend_all = Time.now
    puts "Time to complete man Graph: #{tend_man - tstart_man} seconds"
    puts "Time to complete hvs Graph: #{tend_hvs - tstart_hvs} seconds"
    puts "Time to complete man AR: #{tend_man_ar - tstart_man_ar} seconds"
    puts "Time to complete hvs AR: #{tend_hvs_ar - tstart_hvs_ar} seconds"
    puts "Time to complete mix AR: #{tend_ar_mix - tstart_ar_mix} seconds"
    puts "Time to complete all: #{tend_all - tstart_all} seconds"
    # puts "Accuracy: #{100 - closest.count}%"
  end

  desc "Benchmark db queries"
  task benchmark_query: :environment do
    tstart = Time.now
      nodes = Graph.intersections
    tend = Time.now
    puts "Total time graph(int): #{tend - tstart}"

    tstart = Time.now
      nodes = Graph.all
    tend = Time.now
    puts "Total time graph (all): #{tend - tstart}"

    tstart = Time.now
      nodes = Node.all.to_a
    tend = Time.now
    puts "Total time ar: #{tend - tstart}"
  end
end