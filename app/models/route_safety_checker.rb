class RouteSafetyChecker
  def initialize(args)
    @midpoint = args[:midpoint]
    @radius = args[:radius]
    @possible_routes = args[:possible_routes]
    @maps_client = GoogleMapsClient.new
    @block_constant = 0.0016
  end

  def run
    @near_crimes = Crime.get_near_crimes(@midpoint, @radius)
    select_safest_route
  end

  private
  def select_safest_route
    ranked_reoutes = return_ranked_routes
  end

  def return_ranked_routes
    ranked_routes = []
    @possible_routes.each do |route|
      ranked_routes << { route: route,
        avg_near_crimes: avg_near_crimes(route),
        max_crimes: max_crimes(route) }
    end
    ranked_routes
  end

  def avg_near_crimes(route)
    @crimes_near_path = []
    route_points = @maps_client.decode_polyline(route["routes"].first["overview_polyline"]["points"])
    route_points.each do |coords|
      @crimes_near_path << crimes_near_node_count(coords)
    end
    @crimes_near_path.reduce(:+).to_f / @crimes_near_path.length
  end

  def max_crimes(route)
    @crimes_near_path.max
  end

  def crimes_near_node_count(coords)
    crimes_near_node = @near_crimes.select { |crime| distance_between_nodes(coords, crime) < @block_constant }
    crimes_near_node.length
  end

  def distance_between_nodes(coords, crime)
    squared_lat = (coords[0] - crime.y.to_f) ** 2
    squared_lng = (coords[1] - crime.x.to_f) ** 2
    Math.sqrt(squared_lat + squared_lng)
  end
end