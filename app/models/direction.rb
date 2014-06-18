class Direction
  attr
  def initialize(args)
    @origin_address = args["origin"]
    @destination_address = args["destination"]
    @maps_client = GoogleMapsClient.new
    geocode_endpoints
  end

  def origin_node
    @origin_node
  end

  def destination_node
    @destination_node
  end

  def gen_safe_route
    @path_points = Graph.weighted_path(@origin_node, @destination_node)
    { path: @path_points, origin: @origin_address, destination: @destination_address, origin_coords: @origin_coords, destination_coords: @destination_coords }
  end

  private
  def geocode_endpoints
    if @origin_address && @destination_address
      @origin_coords = @maps_client.point_geocode(@origin_address)
      @destination_coords = @maps_client.point_geocode(@destination_address)
    end
    @origin_node = find_closest_node(@origin_coords)
    @destination_node = find_closest_node(@destination_coords)
  end

  def find_closest_node(node_latlon)
    nodes = Node.all.to_a
    close_nodes = []
    nodes.each do |node|
      distance = Node.distance_between_points(node, node_latlon)
      if distance < 0.0016
        close_nodes << { node: node, distance: distance }
      end
    end
    close_nodes.sort_by{|node| node[:distance]}.first[:node]
  end
end