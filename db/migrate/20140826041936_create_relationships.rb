class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.belongs_to :node, as: :start_node
      t.belongs_to :node, as: :end_node
      t.decimal :crime_rating
      t.decimal :distance
      t.decimal :gradient
      t.decimal :weight_safest_12
      t.decimal :weight_safest_14
      t.decimal :weight_safest_18
      t.decimal :weight_shortestr
    end
  end
end
