class GoogleMapsClient
  def point_geocode(address)
    response = HTTParty.get("https://maps.googleapis.com/maps/api/geocode/json",
      query: { address: address })
    location = response.parsed_response["results"][0]["geometry"]["location"]
    { lat: location["lat"], lon: location["lng"] }
  end

  # def get_route(start_position, end_position, waypoint = [])
  #   response = HTTParty.get("http://maps.googleapis.com/maps/api/directions/json",
  #     query: {origin: "#{start_position[:lat]},#{start_position[:lon]}",
  #             destination: "#{end_position[:lat]},#{end_position[:lon]}",
  #             waypoints: "via:#{waypoint[:lat]},#{waypoint[:lon]}",
  #             mode: "walking"})
  #   response
  # end

  # def get_initial_route(start_position, end_position)
  #   response = HTTParty.get("http://maps.googleapis.com/maps/api/directions/json",
  #     query: {origin: "#{start_position[:lat]},#{start_position[:lon]}",
  #             destination: "#{end_position[:lat]},#{end_position[:lon]}",
  #             mode: "walking"})
  #   response
  # end

  def decode_polyline(poly_str)
    Polylines::Decoder.decode_polyline(poly_str)
  end

  def encode_polyline(points)
    Polylines::Encoder.encode_points(points)
  end
end