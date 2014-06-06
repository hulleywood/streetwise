class Highway < ActiveRecord::Base
  has_many :waypoints
  has_many :nodes, through: :waypoints
end