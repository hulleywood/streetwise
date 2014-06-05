class Direction
  def initialize(args)
    @start_point = args["start_point"]
    @end_point = args["end_point"]
    @maps_client = GoogleMapsClient.new
  end

  def calc_safe_route
    if endpoints_are_valid
      start_time = Time.now
      route = get_safe_route
      end_time = Time.now
      puts "Total process took: #{end_time - start_time} seconds"
      route
    end
  end

  private
  def endpoints_are_valid
    if @start_point && @end_point
      @start_position = @maps_client.point_geocode(@start_point)
      @end_position = @maps_client.point_geocode(@end_point)
    end

    !!(@start_position && @end_position)
  end

  def get_safe_route
    initial_route_args = { start_position: @start_position,
                            end_position: @end_position }
    initial_route = MassDirectionGenerator.new(initial_route_args).run

    waypoint_args = { start_position: @start_position, end_position: @end_position, initial_route: initial_route }
    waypoint_generator = WaypointGenerator.new(waypoint_args)
    waypoints = waypoint_generator.run
    print_waypoints(waypoints)
    mass_direction_args = { start_position: @start_position,
                            end_position: @end_position,
                            waypoints: waypoints }
    possible_routes = MassDirectionGenerator.new(mass_direction_args).run

    safest_route_args = { midpoint: waypoint_generator.midpoint,
                          radius: waypoint_generator.radius,
                          possible_routes: possible_routes }
    safest_route = RouteSafetyChecker.new(safest_route_args).run
  end

  def print_waypoints(waypoints)
    waypoints.each do |waypoint|
      puts "#{waypoint[:lat]}, #{waypoint[:lng]}"
    end
  end
end