class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.belongs_to :start_node, class_name: 'Node'
      t.belongs_to :end_node, class_name: 'Node'
      t.decimal :crime_rating
      t.decimal :distance
      t.decimal :gradient
      t.decimal :weight_safest_12
      t.decimal :weight_safest_14
      t.decimal :weight_safest_18
      t.decimal :weight_shortest
    end
  end
end
