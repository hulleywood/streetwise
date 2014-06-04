class MassDirectionGenerator
  def initialize(args)
    @start_position = args[:start_position]
    @end_position = args[:end_position]
    @waypoints = args[:waypoints]
    @maps_client = GoogleMapsClient.new
  end

  def run
    possible_routes = []
    @waypoints.each do |waypoint|
      possible_routes << @maps_client.get_route(@start_position, @end_position, waypoint)
    end
    possible_routes
  end
end