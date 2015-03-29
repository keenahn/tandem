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

ActiveRecord::Schema.define(version: 20150329073258) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.boolean  "active",      default: true, null: false
  end

  add_index "pairs", ["active"], name: "index_pairs_on_active", using: :btree
  add_index "pairs", ["activity"], name: "index_pairs_on_activity", using: :btree
  add_index "pairs", ["group_id"], name: "index_pairs_on_group_id", using: :btree
  add_index "pairs", ["member_1_id"], name: "index_pairs_on_member_1_id", using: :btree
  add_index "pairs", ["member_2_id"], name: "index_pairs_on_member_2_id", using: :btree

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
