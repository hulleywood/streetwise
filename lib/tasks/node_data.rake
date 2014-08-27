namespace :node_data do

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

  desc 'Create pg relationships'
  task create_pg_rels: :environment do
    tstart = Time.now

    Dir.chdir('./lib/assets')
    file = File.join( Dir.pwd, '/graph_intersects_rels.csv')

    csv_data = CSV.read(file)
    headers = csv_data.shift

    string_data = csv_data.map {|row| row.map {|cell| cell.to_s } }
    array_of_hashes = string_data.map {|row| Hash[*headers.zip(row).flatten] }

    array_of_hashes.each do |args|
      Relationship.create_from_csv_args(args)
    end

    tend = Time.now
    puts "Total time to complete: #{tend - tstart} seconds"
  end

  desc 'Convert elevation to miles'
  task meters_to_miles: :environment do
    nodes = Node.all.to_a

    nodes.each do |n|
      if n.elevation
        n.elevation = meters_to_miles(n.elevation)
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

def meters_to_miles(meters)
  ((meters * 3.28084)/5280.0).round(5)
end