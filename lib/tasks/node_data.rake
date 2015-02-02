namespace :node_data do
  desc 'Create neighbor relationships'
  task create_neighbor_relationships: :environment do
    tstart = Time.now

    nodes = Node.all
    puts "Creating relationships for #{nodes.length} nodes"

    nodes.each do |node|
      wpts = node.waypoints
      wpts.each { |wpt| Relationship.create_neighbors(node, wpt) }
    end

    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end

  desc 'Weight relationships'
  task weight_relationships: :environment do
    tstart = Time.now

    batch_of_threads = []
    pool_size = 10
    batch_size = Relationship.count/pool_size
    puts "Weighting #{pool_size} batches of #{batch_size} relationships"

    Relationship.find_in_batches(batch_size: batch_size) do |batch|
      thr = Thread.new(batch) do |rels|
        rels.each do |rel|
          rel.normalize_relationship_properties
          rel.set_relationship_weights
          rel.save
        end
        puts "Relationship group finished"
      end
      batch_of_threads << thr
    end

    batch_of_threads.map(&:join)
    tend = Time.now
    puts "Time to complete: #{tend - tstart} seconds"
  end

  desc 'Add elevation to nodes'
  task add_elevation_to_nodes: :environment do
    tstart = Time.now
    base_uri = "https://maps.googleapis.com/maps/api/elevation/json?locations="

    Node.find_in_batches(batch_size: 75) do |group|
      request = base_uri
      group.each_with_index do |n, i|
        i == 0 ? (request += "#{n.lat},#{n.lon}") : (request += "|#{n.lat},#{n.lon}")
      end

      response = HTTParty.get(URI::encode(request))
      parsed = JSON.parse(response.body)
      p parsed

      if parsed["results"] && parsed["results"].length > 0
        group.each_with_index do |n, i|
          elevation = parsed["results"][i]["elevation"].to_f
          n.elevation = meters_to_feet(elevation) if elevation
          n.save
        end
      end
      sleep(1.1)
    end

    tend = Time.now
    puts "Total time to complete: #{tend - tstart} seconds"
  end

  desc 'Convert elevation to feet'
  task meters_to_feet: :environment do
    nodes = Node.all.to_a

    nodes.each do |n|
      if n.elevation
        n.elevation = meters_to_feet(n.elevation)
        n.save
      end
    end
  end

  desc 'Calculate attribute coefficients'
  task calc_coefficients: :environment do
    tstart = Time.now

    qty_rels = Relationship.count

    total_distance = Relationship.sum(:distance)
    max_distance = Relationship.maximum(:distance)
    min_distance = Relationship.minimum(:distance)
    avg_distance = total_distance/qty_rels
    coeff_distance = 1/max_distance 

    total_crime_rating = Relationship.sum(:crime_rating)
    max_crime = Relationship.maximum(:crime_rating)
    min_crime = Relationship.minimum(:crime_rating)
    avg_crime = total_crime_rating/qty_rels
    coeff_crime = 1/max_crime

    total_gradient = Relationship.sum(:gradient)
    max_gradient = Relationship.maximum(:gradient)
    min_gradient = Relationship.minimum(:gradient)
    avg_gradient = total_gradient/qty_rels
    coeff_gradient = 1/max_gradient

    puts "Distance: avg = #{avg_distance}, max = #{max_distance}, min = #{min_distance}, coefficient = #{coeff_distance}"
    puts "Crime Rating: avg = #{avg_crime}, max = #{max_crime}, min = #{min_crime}, coefficient = #{coeff_crime}"
    puts "Gradient: avg = #{avg_gradient}, max = #{max_gradient}, min = #{min_gradient}, coefficient = #{coeff_gradient}"

    tend = Time.now
    puts "Total time to complete: #{tend - tstart} seconds"
  end
end

def meters_to_feet(meters)
  (meters * 3.28084).round(5)
end
