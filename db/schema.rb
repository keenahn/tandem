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

ActiveRecord::Schema.define(version: 20150119150011) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: true do |t|
    t.string   "language"
    t.string   "present_indicative"
    t.string   "present_particple"
    t.string   "past_participle"
    t.string   "noun"
    t.string   "short_noun"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", force: true do |t|
    t.integer  "user_id"
    t.text     "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["user_id"], name: "index_groups_on_user_id", using: :btree

  create_table "groups_members", force: true do |t|
    t.integer "group_id"
    t.integer "member_id"
  end

  add_index "groups_members", ["group_id"], name: "index_groups_members_on_group_id", using: :btree
  add_index "groups_members", ["member_id"], name: "index_groups_members_on_member_id", using: :btree

  create_table "members", force: true do |t|
    t.string   "name"
    t.string   "phone_number"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "members_pairs", force: true do |t|
    t.integer "member_id"
    t.integer "pair_id"
  end

  add_index "members_pairs", ["member_id"], name: "index_members_pairs_on_member_id", using: :btree
  add_index "members_pairs", ["pair_id"], name: "index_members_pairs_on_pair_id", using: :btree

  create_table "pairs", force: true do |t|
    t.integer  "group_id"
    t.integer  "user_id_1"
    t.integer  "user_id_2"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pairs", ["group_id"], name: "index_pairs_on_group_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.boolean  "admin"
    t.string   "name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
