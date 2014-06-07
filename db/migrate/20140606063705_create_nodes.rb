class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.string :osm_node_id
      t.float :lat
      t.float :lon
      t.boolean :intersection, default: false
      t.float :crime_rating
      t.index :osm_node_id
      t.timestamps
    end
  end
end
