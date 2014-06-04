class Crime < ActiveRecord::Base
  def self.get_near_crimes(midpoint, radius)
    lat_range = Crime.get_lat_range(midpoint, radius)
    lng_range = Crime.get_lng_range(midpoint, radius)
    Crime.where(y: lat_range, x: lng_range)
  end

  def self.get_lat_range(midpoint, radius)
    if midpoint[:lat] > 0
      (midpoint[:lat] - radius).to_s..(midpoint[:lat] + radius).to_s
    else
      (midpoint[:lat] + radius).to_s..(midpoint[:lat] - radius).to_s
    end
  end

  def self.get_lng_range(midpoint, radius)
    if midpoint[:lng] > 0
      (midpoint[:lng] - radius).to_s..(midpoint[:lng] + radius).to_s
    else
      (midpoint[:lng] + radius).to_s..(midpoint[:lng] - radius).to_s
    end
  end
end