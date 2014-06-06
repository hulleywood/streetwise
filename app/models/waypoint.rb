class Waypoint < ActiveRecord::Base
  belongs_to :node
  belongs_to :highway
end