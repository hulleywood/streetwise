class GoogleMapsClient
  def point_geocode(address)
    response = HTTParty.get("https://maps.googleapis.com/maps/api/geocode/json",
      query: { address: address })
    location = response.parsed_response["results"][0]["geometry"]["location"]
    { lat: location["lat"], lon: location["lng"] }
  end

  def decode_polyline(poly_str)
    Polylines::Decoder.decode_polyline(poly_str)
  end

  def encode_polyline(points)
    Polylines::Encoder.encode_points(points)
  end
end