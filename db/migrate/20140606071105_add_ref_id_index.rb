class AddRefIdIndex < ActiveRecord::Migration
  def change
    add_index :nodes, :ref_id
  end
end
