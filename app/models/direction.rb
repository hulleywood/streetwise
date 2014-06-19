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

  def gen_paths
    @paths = Graph.get_paths(@origin_node, @destination_node)
    { paths: @paths, origin: @origin_address, destination: @destination_address, origin_coords: @origin_coords, destination_coords: @destination_coords }
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

  def find_closest_node(coords)
    close_nodes = Node.close_nodes(coords)
    close_nodes.first[:node]
  end
end