class Crime < ActiveRecord::Base
  def self.get_near_crimes(midpoint, radius)
    max_lat = midpoint[:k] + radius
    min_lat = midpoint[:k] - radius
    max_long = midpoint[:A] + radius
    min_long = midpoint[:A] - radius
    Crime.where(y: (min_lat.to_s)..(max_lat.to_s))
  end
end