class Crime < ActiveRecord::Base
  validates :x, presence: true
  validates :y, presence: true
  validates :date, presence: true

  def self.count_near_crimes(node, radius = 0.0016)
    lat_range = Node.coord_range(node[:lat], radius)
    lon_range = Node.coord_range(node[:lon], radius)
    Crime.where(y: lat_range, x: lon_range).size
  end
end
