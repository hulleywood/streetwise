class CreateWaypoints < ActiveRecord::Migration
  def change
    create_table :waypoints do |t|
      t.string :way_ref
      t.string :node_ref
    end
  end
end
