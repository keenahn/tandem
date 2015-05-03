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

ActiveRecord::Schema.define(version: 20150503033125) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "checkins", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "pair_id"
    t.date     "local_date"
    t.datetime "done_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "checkins", ["member_id", "local_date"], name: "index_checkins_on_member_id_and_local_date", using: :btree
  add_index "checkins", ["pair_id", "member_id", "local_date"], name: "index_checkins_on_pair_id_and_member_id_and_local_date", unique: true, using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "group_memberships", force: :cascade do |t|
    t.integer  "group_id",   null: false
    t.integer  "member_id",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "group_memberships", ["group_id", "member_id"], name: "index_group_memberships_on_group_id_and_member_id", unique: true, using: :btree
  add_index "group_memberships", ["group_id"], name: "index_group_memberships_on_group_id", using: :btree
  add_index "group_memberships", ["member_id"], name: "index_group_memberships_on_member_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.integer  "owner_id"
    t.text     "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_zone",   default: "Pacific Time (US & Canada)"
    t.string   "activity"
  end

  add_index "groups", ["activity"], name: "index_groups_on_activity", using: :btree
  add_index "groups", ["owner_id"], name: "index_groups_on_owner_id", using: :btree

  create_table "members", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "phone_number", limit: 255
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_zone",                default: "Pacific Time (US & Canada)"
  end

  create_table "pairs", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "member_1_id"
    t.integer  "member_2_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "activity"
    t.boolean  "active",            default: true, null: false
    t.string   "tandem_number"
    t.string   "time_zone"
    t.time     "reminder_time_mon"
    t.time     "reminder_time_tue"
    t.time     "reminder_time_wed"
    t.time     "reminder_time_thu"
    t.time     "reminder_time_fri"
    t.time     "reminder_time_sat"
    t.time     "reminder_time_sun"
  end

  add_index "pairs", ["active"], name: "index_pairs_on_active", using: :btree
  add_index "pairs", ["activity"], name: "index_pairs_on_activity", using: :btree
  add_index "pairs", ["group_id"], name: "index_pairs_on_group_id", using: :btree
  add_index "pairs", ["member_1_id"], name: "index_pairs_on_member_1_id", using: :btree
  add_index "pairs", ["member_2_id"], name: "index_pairs_on_member_2_id", using: :btree
  add_index "pairs", ["tandem_number", "member_1_id"], name: "index_pairs_on_tandem_number_and_member_1_id", using: :btree
  add_index "pairs", ["tandem_number", "member_2_id"], name: "index_pairs_on_tandem_number_and_member_2_id", using: :btree

  create_table "reminders", force: :cascade do |t|
    t.integer  "pair_id"
    t.integer  "member_id"
    t.integer  "status",        default: 0
    t.integer  "integer",       default: 0
    t.datetime "next_utc_time"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "reminders", ["member_id"], name: "index_reminders_on_member_id", using: :btree
  add_index "reminders", ["pair_id"], name: "index_reminders_on_pair_id", using: :btree
  add_index "reminders", ["status", "next_utc_time"], name: "index_reminders_on_status_and_next_utc_time", using: :btree

  create_table "sms", force: :cascade do |t|
    t.integer  "from_id"
    t.string   "from_type"
    t.integer  "to_id"
    t.string   "to_type"
    t.string   "from_number"
    t.string   "to_number"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sms", ["from_id", "from_type"], name: "index_sms_on_from_id_and_from_type", using: :btree
  add_index "sms", ["from_number"], name: "index_sms_on_from_number", using: :btree
  add_index "sms", ["to_id", "to_type"], name: "index_sms_on_to_id_and_to_type", using: :btree
  add_index "sms", ["to_number"], name: "index_sms_on_to_number", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",                           null: false
    t.string   "encrypted_password",     limit: 255, default: "",                           null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,                            null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username",               limit: 255
    t.boolean  "admin"
    t.string   "name",                   limit: 255
    t.string   "time_zone",                          default: "Pacific Time (US & Canada)"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
