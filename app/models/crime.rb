class Crime < ActiveRecord::Base
  validates :x, presence: true
  validates :y, presence: true
  validates :date, presence: true

  def self.get_near_crimes(node, radius = 0.0016)
    lat_range = Crime.get_lat_range(node, radius)
    lon_range = Crime.get_lon_range(node, radius)
    Crime.where(y: lat_range, x: lon_range)
  end

  private
  def self.get_lat_range(node, radius)
    if node[:lat] > 0
      (node[:lat] - radius).to_s..(node[:lat] + radius).to_s
    else
      (node[:lat] + radius).to_s..(node[:lat] - radius).to_s
    end
  end

  def self.get_lon_range(node, radius)
    if node[:lon] > 0
      (node[:lon] - radius).to_s..(node[:lon] + radius).to_s
    else
      (node[:lon] + radius).to_s..(node[:lon] - radius).to_s
    end
  end
end