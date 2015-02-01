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


  desc 'Add elevation to nodes'
  task add_elevation_to_nodes: :environment do
    tstart = Time.now
    base_uri = "https://maps.googleapis.com/maps/api/elevation/json?locations="

    Node.where(intersection: true, elevation: nil).find_in_batches(batch_size: 75) do |group|
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
          n.elevation = meters_to_miles(elevation) if elevation
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

  desc 'Add gradient to relationships'
  task gradient_to_rels: :environment do
    rels = Relationship.all

    rels.each do |r|
      rise = (r.start_node.elevation - r.end_node.elevation).abs
      run = r.distance
      slope = rise/run
      grad = (slope**2)*run
      r.gradient = grad
      r.save
    end
  end
end

def meters_to_feet(meters)
  (meters * 3.28084).round(5)
end
