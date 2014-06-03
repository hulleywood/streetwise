class CreateCrimes < ActiveRecord::Migration
  def change
    create_table :crimes do |t|
      t.string      :time
      t.string      :category
      t.string      :pddistrict
      t.string      :address
      t.string      :descript
      t.string      :dayofweek
      t.string      :resolution
      t.timestamp   :date
      t.string      :y
      t.string      :x
      t.string      :incidntnum

      t.timestamps
    end
  end
end
