class WaypointGenerator
  attr_reader :midpoint, :radius

  def initialize(args)
    @start_position = args[:start_position]
    @end_position = args[:end_position]
    @initial_route = args[:initial_route]
    @initial_points = get_initial_points
    @step_size = 0.001
  end

  def run
    @midpoint = calc_midpoint
    @radius = calc_radius
    generate_waypoints
  end

  private
  def get_initial_points
    polyline = @initial_route.first["routes"].first["overview_polyline"]["points"]
    GoogleMapsClient.new.decode_polyline(polyline)
  end

  def calc_midpoint
    midpoint_lat = (@end_position[:lat] - @start_position[:lat]) / 2 + @start_position[:lat]
    midpoint_long = (@end_position[:lon] - @start_position[:lon]) / 2 + @start_position[:lon]
    { lat: midpoint_lat, lon: midpoint_long }
  end

  def calc_radius
    squared_lat = (@end_position[:lat] - @start_position[:lat]) ** 2
    squared_lon = (@end_position[:lon] - @start_position[:lon]) ** 2
    hypot = Math.sqrt(squared_lat + squared_lon)
    hypot/2
  end

  def generate_waypoints
    waypoints = []
    @initial_points.each do |point|
      waypoints << get_radial_points(point)
    end
    remove_redundant_points(waypoints.flatten)
  end

  def get_radial_points(point)
    waypoints = []
    3.times do |i|
      waypoints << { lat: point[0] + @step_size * i, lon: point[1] + @step_size * i }
      waypoints << { lat: point[0] + @step_size * i, lon: point[1] - @step_size * i }
      waypoints << { lat: point[0] - @step_size * i, lon: point[1] + @step_size * i }
      waypoints << { lat: point[0] - @step_size * i, lon: point[1] - @step_size * i }
    end
    waypoints
  end

  def remove_redundant_points(points)
    points.map! { |point| { lat: (point[:lat] * 1000).round/1000.0, lon: (point[:lon] * 1000).round/1000.0 } }
    points.uniq!
  end
end