class WaypointGenerator
  attr_reader :midpoint, :radius

  def initialize(args)
    @start_position = args[:start_position]
    @end_position = args[:end_position]
    @num_steps = 3
  end

  def run
    @midpoint = calc_midpoint
    @radius = calc_radius
    @south_point = calc_south_point
    @east_point = calc_east_point
    waypoints = generate_waypoints
  end

  private
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

  def calc_south_point
    if @midpoint[:lat] > 0
      { lat: (@midpoint[:lat] - @radius), lng: @midpoint[:lng] }
    else
      { lat: (@midpoint[:lat] + @radius), lng: @midpoint[:lng] }
    end
  end

  def calc_east_point
    if @midpoint[:lng] > 0
      { lat: @midpoint[:lat], lng: (@midpoint[:lng] - @radius) }
    else
      { lat: @midpoint[:lat], lng: (@midpoint[:lng] + @radius) }
    end
  end

  def generate_waypoints
    waypoints = []
    waypoints << add_vertical_waypoints
    waypoints << add_horizontal_waypoints
    waypoints.flatten
  end

  def add_vertical_waypoints
    waypoints = []
    step = @radius/@num_steps
    (2 * @num_steps - 1).times do |i|
      waypoints << { lat: (@south_point[:lat] + step * (i + 1)), lng: @south_point[:lng] }
    end
    waypoints
  end

  def add_horizontal_waypoints
    waypoints = []
    step = @radius/@num_steps
    (2 * @num_steps - 1).times do |i|
      waypoints << { lat: @east_point[:lat], lng: (@east_point[:lng] - step * (i + 1)) }
    end
    waypoints
  end
end