# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_08_26_113354) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "email_addresses", force: :cascade do |t|
    t.string "address", null: false
    t.bigint "owner_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "activation_digest"
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.index ["address"], name: "index_email_addresses_on_address", unique: true
    t.index ["owner_id"], name: "index_email_addresses_on_owner_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.date "birthday"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "personable_type", null: false
    t.integer "personable_id", null: false
    t.index ["personable_type", "personable_id"], name: "index_people_on_personable_type_and_personable_id", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "email_address_id"
    t.index ["email_address_id"], name: "index_sessions_on_email_address_id"
    t.index ["user_id", "created_at"], name: "index_sessions_on_user_id_and_created_at", unique: true
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "email_addresses", "people", column: "owner_id"
  add_foreign_key "sessions", "email_addresses"
  add_foreign_key "sessions", "users"
end
