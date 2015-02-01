class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      #general attributes
      t.belongs_to :start_node, class_name: 'Node', foreign_key: 'node_id'
      t.belongs_to :end_node, class_name: 'Node', foreign_key: 'node_id'
      t.belongs_to :node
      t.boolean :intersectional
      t.timestamps

      #environmental factors
      t.decimal :crime_rating
      t.decimal :distance
      t.decimal :gradient

      #normalized env factors
      t.decimal :n_crime_rating
      t.decimal :n_dist
      t.decimal :n_grad_out
      t.decimal :n_grad_in
      t.decimal :nw_grad_out
      t.decimal :nw_grad_in

      #pre-calculated wieghts outgoing
      t.decimal :w_d8c1_o
      t.decimal :w_d4c1_o
      t.decimal :w_d2c1_o
      t.decimal :w_d1c1_o
      t.decimal :w_d1g1_o
      t.decimal :w_d1g2_o
      t.decimal :w_d1g4_o
      t.decimal :w_d1g8_o
      t.decimal :w_d2g1_o
      t.decimal :w_d4g1_o
      t.decimal :w_d8g1_o
      t.decimal :w_c1g1_o
      t.decimal :w_c2g1_o
      t.decmial :w_c4g1_o
      t.decimal :w_c8g1_o
      t.decimal :w_c1g2_o
      t.decimal :w_c1g4_o
      t.decimal :w_c1g8_o

      #pre-calculated wieghts incoming
      t.decimal :w_d8c1_i
      t.decimal :w_d4c1_i
      t.decimal :w_d2c1_i
      t.decimal :w_d1c1_i
      t.decimal :w_d1g1_i
      t.decimal :w_d1g2_i
      t.decimal :w_d1g4_i
      t.decimal :w_d1g8_i
      t.decimal :w_d2g1_i
      t.decimal :w_d4g1_i
      t.decimal :w_d8g1_i
      t.decimal :w_c1g1_i
      t.decimal :w_c2g1_i
      t.decmial :w_c4g1_i
      t.decimal :w_c8g1_i
      t.decimal :w_c1g2_i
      t.decimal :w_c1g4_i
      t.decimal :w_c1g8_i
    end
  end
end
