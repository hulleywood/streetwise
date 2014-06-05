class WaypointGenerator
  attr_reader :midpoint, :radius

  def initialize(args)
    @start_position = args[:start_position]
    @end_position = args[:end_position]
    @initial_route = args[:initial_route]
    @initial_points = get_initial_points
    @step_size = 0.002
    @close_waypoint_dist = 0.005
  end

  def run
    @midpoint = calc_midpoint
    @radius = calc_radius
    # @num_steps = ((@radius * 2)/@step_size).to_i
    # @south_point = calc_south_point
    # @east_point = calc_east_point
    # @south_east_point = calc_south_east_point
    # puts @south_east_point
    waypoints = generate_waypoints
    puts waypoints.length
    waypoints
    # new_way = return_close_waypoints(waypoints)
    # puts new_way.length
    # new_way
  end

  private
  def get_initial_points
    polyline = @initial_route.first["routes"].first["overview_polyline"]["points"]
    GoogleMapsClient.new.decode_polyline(polyline)
  end

  def return_close_waypoints(waypoints)
    waypoints.reject do |waypoint|
      distance_to_closest_point(waypoint) > @close_waypoint_dist
    end
  end

  def distance_to_closest_point(waypoint)
    distances = @initial_points.map do |point|
      distance_between_nodes(point, waypoint)
    end
    # puts distances
    distances.min
  end

  def distance_between_nodes(point, waypoint)
    squared_lat = (point[0] - waypoint[:lat]) ** 2
    squared_lng = (point[1] - waypoint[:lng]) ** 2
    Math.sqrt(squared_lat + squared_lng)
  end

  def calc_midpoint
    midpoint_lat = (@end_position[:lat] - @start_position[:lat]) / 2 + @start_position[:lat]
    midpoint_long = (@end_position[:lng] - @start_position[:lng]) / 2 + @start_position[:lng]
    { lat: midpoint_lat, lng: midpoint_long }
  end

  def calc_radius
    squared_lat = (@end_position[:lat] - @start_position[:lat]) ** 2
    squared_lng = (@end_position[:lng] - @start_position[:lng]) ** 2
    hypot = Math.sqrt(squared_lat + squared_lng)
    hypot/2
  end

  # def calc_south_east_point
  #   { lat: calc_south_point[:lat], lng: calc_east_point[:lng] }
  # end

  # def calc_south_point
  #   if @midpoint[:lat] > 0
  #     { lat: (@midpoint[:lat] - @radius), lng: @midpoint[:lng] }
  #   else
  #     { lat: (@midpoint[:lat] + @radius), lng: @midpoint[:lng] }
  #   end
  # end

  # def calc_east_point
  #   if @midpoint[:lng] > 0
  #     { lat: @midpoint[:lat], lng: (@midpoint[:lng] - @radius) }
  #   else
  #     { lat: @midpoint[:lat], lng: (@midpoint[:lng] + @radius) }
  #   end
  # end

  def generate_waypoints
    waypoints = []
    # waypoints << add_vertical_waypoints
    # waypoints << add_horizontal_waypoints
    @initial_points.each do |point|
      waypoints << get_radial_points(point)
    end
    remove_redundant_points(waypoints.flatten)
  end

  def get_radial_points(point)
    waypoints = []
    3.times do |i|
      waypoints << { lat: point[0] + @step_size * i, lng: point[1] + @step_size * i }
      waypoints << { lat: point[0] + @step_size * i, lng: point[1] - @step_size * i }
      waypoints << { lat: point[0] - @step_size * i, lng: point[1] + @step_size * i }
      waypoints << { lat: point[0] - @step_size * i, lng: point[1] - @step_size * i }
    end
    waypoints
  end

  def remove_redundant_points(points)
    points.map! { |point| { lat: (point[:lat] * 200).round/200.0, lng: (point[:lng] * 200).round/200.0 } }
    points.uniq!
  end

  # def add_vertical_waypoints
  #   waypoints = []
  #   @num_steps.times do |i|
  #     waypoints << { lat: (@south_point[:lat] + @step_size * (i + 1)), lng: @south_point[:lng] }
  #   end
  #   waypoints
  # end

  # def add_horizontal_waypoints
  #   waypoints = []
  #   @num_steps.times do |i|
  #     waypoints << { lat: @east_point[:lat], lng: (@east_point[:lng] - @step_size * (i + 1)) }
  #   end
  #   waypoints
  # end
end