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

ActiveRecord::Schema.define(version: 20140401214444) do

  create_table "employee_availabilities", force: true do |t|
    t.datetime "start_datetime"
    t.datetime "end_datetime"
    t.integer  "employee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "schedule_id"
  end

  create_table "employee_schedules", force: true do |t|
    t.integer  "schedule_id"
    t.integer  "employee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "availability_submitted", default: false
  end

  create_table "employees", force: true do |t|
    t.integer  "global_max_hours"
    t.string   "email"
    t.string   "name"
    t.boolean  "is_disabled",          default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "profile_file_name"
    t.string   "profile_content_type"
    t.integer  "profile_file_size"
    t.datetime "profile_updated_at"
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
    t.boolean  "is_disabled", default: false
  end

  create_table "organizations", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.integer  "rm_id"
  end

  create_table "organizations_users", force: true do |t|
    t.integer  "user_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schedules", force: true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "state",           default: 1
    t.string   "name"
    t.integer  "organization_id"
    t.integer  "max_hours"
  end

  create_table "shift_assignment_statuses", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shift_assignments", force: true do |t|
    t.datetime "start_datetime"
    t.datetime "end_datetime"
    t.integer  "employee_id"
    t.boolean  "is_confirmed",   default: false
    t.integer  "shift_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status_id",      default: 1
  end

  create_table "shifts", force: true do |t|
    t.datetime "start_datetime"
    t.datetime "end_datetime"
    t.boolean  "is_mandatory",   default: false
    t.integer  "location_id"
    t.integer  "skill_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "schedule_id"
  end

  create_table "skill_assignments", force: true do |t|
    t.integer  "employee_id"
    t.integer  "skill_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "skills", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_disabled", default: false
  end

  create_table "users", force: true do |t|
    t.string   "loginid"
    t.integer  "employee_id"
    t.boolean  "is_manager",   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "disabled",     default: false
    t.datetime "logged_in_at"
  end

  create_table "wages", force: true do |t|
    t.integer  "amount"
    t.integer  "employee_id"
    t.date     "starting_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
