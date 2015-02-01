class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.boolean :intersectional
      t.belongs_to :start_node, class_name: 'Node', foreign_key: 'node_id'
      t.belongs_to :end_node, class_name: 'Node', foreign_key: 'node_id'
      t.belongs_to :node
      t.decimal :crime_rating
      t.decimal :normalized_crime_rating
      t.decimal :distance
      t.decimal :normalized_distance
      t.decimal :gradient
      t.decimal :normalized_gradient
      t.decimal :w_d8c1
      t.decimal :w_d4c1
      t.decimal :w_d2c1
      t.decimal :w_d1c1
      t.decimal :w_d1g1
      t.decimal :w_d1g2
      t.decimal :w_d1g4
      t.decimal :w_d1g8
      t.decimal :w_d2g1
      t.decimal :w_d4g1
      t.decimal :w_d8g1
      t.decimal :w_c1g1
      t.decimal :w_c2g1
      t.decmial :w_c4g1
      t.decimal :w_c8g1
      t.decimal :w_c1g2
      t.decimal :w_c1g4
      t.decimal :w_c1g8
    end
  end
end
