class Direction
  attr
  def initialize(args)
    @origin_address = args["origin"]
    @destination_address = args["destination"]
    tstart = Time.now
    puts "Beginning geocode"
    geocode_endpoints
    tend = Time.now
    puts "Geocode over. Time to complete #{tend - tstart}"
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
      @origin_coords = point_geocode(@origin_address)
      @destination_coords = point_geocode(@destination_address)
    end

    # nodes = Graph.all
    # @origin_node = Graph.get_nearest_node_man(@origin_coords, nodes)
    # @destination_node = Graph.get_nearest_node_man(@destination_coords, nodes)
    @origin_node = Node.closest_node({ coords: @origin_coords, intersection: true })
    @destination_node = Node.closest_node({ coords: @destination_coords, intersection: true })
  end

  def point_geocode(address)
    coords = Geocoder.coordinates(address)
    { "lat" => coords[0], "lon" => coords[1] }
  end

  def find_closest_node(coords)
    close_nodes = Node.closest_nodes({ coords: coords, intersection: true })
    close_nodes.first[:node] if close_nodes.first
  end
end