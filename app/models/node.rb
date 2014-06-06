class Node < ActiveRecord::Base
  has_many :waypoints
  has_many :highways, through: :waypoints
end