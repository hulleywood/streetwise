class Direction
  def initialize(args)
    @start_point = args["start_point"]
    @end_point = args["end_point"]
    @maps_client = GoogleMapsClient.new
  end

  def calc_safe_route
    if endpoints_are_valid
      start_time = Time.now
      # route = get_safe_route
      route = get_dijkstra_route
      end_time = Time.now
      puts "Total process took: #{end_time - start_time} seconds"
      route
    end
  end

#   def get_dijkstra_route
    
#   end

#  1  function Dijkstra(Graph, source):
#  2      dist[source]  := 0                     // Distance from source to source
#  3      for each vertex v in Graph:            // Initializations
#  4          if v ≠ source
#  5              dist[v]  := infinity           // Unknown distance function from source to v
#  6              previous[v]  := undefined      // Previous node in optimal path from source
#  7          end if 
#  8          add v to Q                         // All nodes initially in Q
#  9      end for
# 10      
# 11      while Q is not empty:                  // The main loop
# 12          u := vertex in Q with min dist[u]  // Source node in first case
# 13          remove u from Q 
# 14          
# 15          for each neighbor v of u:           // where v has not yet been removed from Q.
# 16              alt := dist[u] + length(u, v)
# 17              if alt < dist[v]:               // A shorter path to v has been found
# 18                  dist[v]  := alt 
# 19                  previous[v]  := u 
# 20              end if
# 21          end for
# 22      end while
# 23      return dist[], previous[]
# 24  end function

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