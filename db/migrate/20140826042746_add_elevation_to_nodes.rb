class AddElevationToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :elevation, :decimal
  end
end
