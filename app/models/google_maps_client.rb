class GoogleMapsClient
  def point_geocode(point)
    response = HTTParty.get("https://maps.googleapis.com/maps/api/geocode/json",
      query: { address: "#{point}" })
    puts response
    location = response.parsed_response["results"][0]["geometry"]["location"]
    { lat: location["lat"], lng: location["lng"] }
  end

  def get_route(start_position, end_position, waypoint = [])
    response = HTTParty.get("http://maps.googleapis.com/maps/api/directions/json",
      query: {origin: "#{start_position[:lat]},#{start_position[:lng]}",
              destination: "#{end_position[:lat]},#{end_position[:lng]}",
              waypoints: "via:#{waypoint[:lat]},#{waypoint[:lng]}",
              mode: "walking"})
    response
  end

  def get_initial_route(start_position, end_position)
    response = HTTParty.get("http://maps.googleapis.com/maps/api/directions/json",
      query: {origin: "#{start_position[:lat]},#{start_position[:lng]}",
              destination: "#{end_position[:lat]},#{end_position[:lng]}",
              mode: "walking"})
    response
  end

  def decode_polyline(poly_str)
    Polylines::Decoder.decode_polyline(poly_str)
  end
end