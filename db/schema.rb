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

ActiveRecord::Schema.define(version: 20140103051216) do

  create_table "places", force: true do |t|
    t.string   "name"
    t.decimal  "lat",        precision: 8, scale: 6
    t.decimal  "lon",        precision: 9, scale: 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trip_segments", force: true do |t|
    t.integer  "trip_id"
    t.integer  "from_place_id"
    t.integer  "to_place_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trip_segments", ["from_place_id"], name: "index_trip_segments_on_from_place_id"
  add_index "trip_segments", ["to_place_id"], name: "index_trip_segments_on_to_place_id"
  add_index "trip_segments", ["trip_id"], name: "index_trip_segments_on_trip_id"

  create_table "trips", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url",        null: false
  end

  add_index "trips", ["url"], name: "index_trips_on_url", unique: true

end
