class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.string :ref_id
      t.float :lat
      t.float :lon
      t.index :ref_id
    end
  end
end
