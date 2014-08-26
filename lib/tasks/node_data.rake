namespace :node_data do

  desc 'Add elevation to nodes'
  task add_elevation_to_nodes: :environment do

    base_uri = "https://maps.googleapis.com/maps/api/elevation/json?locations="

    nodes = Node.all.to_a
    nodes.each do |n|
      return if n.elevation
      return unless n.intersection

      uri_call = base_uri + "#{n.lat},#{n.lon}"
      response = HTTParty.get(uri_call)
      parsed = JSON.parse(response.body)
      if parsed["results"] && parsed["results"].length > 0
        elevation = parsed["results"].first["elevation"].to_f.round(2) if parsed["results"].first["elevation"]
      end

      n.elevation = elevation if elevation && elevation > 0
      n.save
    end
  end

end