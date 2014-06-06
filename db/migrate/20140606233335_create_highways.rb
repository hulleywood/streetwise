class CreateHighways < ActiveRecord::Migration
  def change
    create_table :highways do |t|
      t.string :name
      t.timestamps
    end
  end
end
