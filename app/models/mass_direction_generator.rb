class MassDirectionGenerator
  def initialize(args)
    @start_position = args[:start_position]
    @end_position = args[:end_position]
    @waypoints = args[:waypoints]
    @maps_client = GoogleMapsClient.new
  end

  def run
    possible_routes = []
    threads = []
    if @waypoints
      @waypoints.each do |waypoint|
        thr = Thread.new() do
          possible_routes << @maps_client.get_route(@start_position, @end_position, waypoint)
        end
        threads << thr
      end
      threads.map(&:join)
    else
      possible_routes << @maps_client.get_initial_route(@start_position, @end_position)
    end
    possible_routes.reject { |route| route["routes"] == [] }
  end
end