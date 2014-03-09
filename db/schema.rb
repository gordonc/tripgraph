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

ActiveRecord::Schema.define(version: 20140309044703) do

  create_table "places", force: true do |t|
    t.string   "name"
    t.decimal  "lat",        precision: 8, scale: 6
    t.decimal  "lon",        precision: 9, scale: 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trip_places", force: true do |t|
    t.integer  "ordinal"
    t.integer  "trip_id"
    t.integer  "place_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trip_places", ["place_id"], name: "index_trip_places_on_place_id"
  add_index "trip_places", ["trip_id"], name: "index_trip_places_on_trip_id"

  create_table "trips", force: true do |t|
    t.string   "url"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
