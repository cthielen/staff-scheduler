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

ActiveRecord::Schema.define(version: 20131104223349) do

  create_table "employee_availabilities", force: true do |t|
    t.datetime "start_datetime"
    t.datetime "end_datetime"
    t.integer  "employee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employees", force: true do |t|
    t.integer  "max_hours"
    t.string   "email"
    t.string   "name"
    t.boolean  "disabled"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "location_assignments", force: true do |t|
    t.integer  "location_id"
    t.integer  "employee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shift_assignments", force: true do |t|
    t.datetime "start_datetime"
    t.datetime "end_datetime"
    t.integer  "employee_id"
    t.boolean  "is_absence"
    t.boolean  "is_confirmed"
    t.integer  "shift_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shift_exceptions", force: true do |t|
    t.datetime "start_datetime"
    t.datetime "end_datetime"
    t.integer  "employee_id"
    t.boolean  "is_absence"
    t.integer  "shift_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shifts", force: true do |t|
    t.datetime "start_datetime"
    t.datetime "end_datetime"
    t.boolean  "is_mandatory"
    t.integer  "location_id"
    t.integer  "skill_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "skill_assignments", force: true do |t|
    t.integer  "location_id"
    t.integer  "employee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "skills", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "loginid"
    t.integer  "employee_id"
    t.boolean  "is_manager"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wages", force: true do |t|
    t.integer  "amount"
    t.integer  "employee_id"
    t.date     "starting_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
