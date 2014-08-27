class Direction
  def initialize(args)
    @origin_address = args["addresses"]["origin"]
    @destination_address = args["addresses"]["destination"]
    @graph = RelationalGraph.new()
    find_endpoint_nodes(args["coords"])
  end

  def gen_paths
    # @paths = Graph.get_paths(@origin_node, @destination_node)
    @paths = @graph.get_paths(@origin_node, @destination_node)
    { paths: @paths, origin: @origin_address, destination: @destination_address, origin_coords: @origin_coords, destination_coords: @destination_coords }
  end

  private
  def find_endpoint_nodes(coords)
    @origin_coords = coords["origin"]
    @destination_coords = coords["destination"]
    @origin_node = Node.closest_node( { coords: @origin_coords } )
    @destination_node = Node.closest_node( { coords: @destination_coords } )
  end
end