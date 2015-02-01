# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150122042932) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "crimes", force: true do |t|
    t.string   "time"
    t.string   "category"
    t.string   "pddistrict"
    t.string   "address"
    t.string   "descript"
    t.string   "dayofweek"
    t.string   "resolution"
    t.datetime "date"
    t.string   "y"
    t.string   "x"
    t.string   "incidntnum"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nodes", force: true do |t|
    t.string   "osm_node_id"
    t.float    "lat"
    t.float    "lon"
    t.boolean  "intersection", default: false
    t.float    "crime_rating", default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "elevation"
  end

  add_index "nodes", ["osm_node_id"], name: "index_nodes_on_osm_node_id", using: :btree

  create_table "relationships", force: true do |t|
    t.integer  "start_node_id"
    t.integer  "end_node_id"
    t.integer  "node_id"
    t.boolean  "intersectional"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "crime_rating"
    t.decimal  "distance"
    t.decimal  "gradient"
    t.decimal  "n_crime_rating"
    t.decimal  "n_dist"
    t.decimal  "n_grad_out"
    t.decimal  "n_grad_in"
    t.decimal  "nw_grad_out"
    t.decimal  "nw_grad_in"
    t.decimal  "w_d8c1_o"
    t.decimal  "w_d4c1_o"
    t.decimal  "w_d2c1_o"
    t.decimal  "w_d1c1_o"
    t.decimal  "w_d1g1_o"
    t.decimal  "w_d1g2_o"
    t.decimal  "w_d1g4_o"
    t.decimal  "w_d1g8_o"
    t.decimal  "w_d2g1_o"
    t.decimal  "w_d4g1_o"
    t.decimal  "w_d8g1_o"
    t.decimal  "w_c1g1_o"
    t.decimal  "w_c2g1_o"
    t.decimal  "w_c4g1_o"
    t.decimal  "w_c8g1_o"
    t.decimal  "w_c1g2_o"
    t.decimal  "w_c1g4_o"
    t.decimal  "w_c1g8_o"
    t.decimal  "w_d8c1_i"
    t.decimal  "w_d4c1_i"
    t.decimal  "w_d2c1_i"
    t.decimal  "w_d1c1_i"
    t.decimal  "w_d1g1_i"
    t.decimal  "w_d1g2_i"
    t.decimal  "w_d1g4_i"
    t.decimal  "w_d1g8_i"
    t.decimal  "w_d2g1_i"
    t.decimal  "w_d4g1_i"
    t.decimal  "w_d8g1_i"
    t.decimal  "w_c1g1_i"
    t.decimal  "w_c2g1_i"
    t.decimal  "w_c4g1_i"
    t.decimal  "w_c8g1_i"
    t.decimal  "w_c1g2_i"
    t.decimal  "w_c1g4_i"
    t.decimal  "w_c1g8_i"
  end

  create_table "waypoints", force: true do |t|
    t.string   "osm_node_id"
    t.integer  "previous_node_id"
    t.integer  "next_node_id"
    t.integer  "node_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
