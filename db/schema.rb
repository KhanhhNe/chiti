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

ActiveRecord::Schema[8.0].define(version: 2025_09_10_072144) do
  create_table "event_participants", force: :cascade do |t|
    t.integer "user_id"
    t.integer "expense_event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["expense_event_id"], name: "index_event_participants_on_expense_event_id"
    t.index ["user_id"], name: "index_event_participants_on_user_id"
  end

  create_table "expense_events", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "expense_items", force: :cascade do |t|
    t.string "name"
    t.integer "paid_by_id", null: false
    t.integer "expense_event_id", null: false
    t.float "amount"
    t.date "paid_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expense_event_id"], name: "index_expense_items_on_expense_event_id"
    t.index ["paid_by_id"], name: "index_expense_items_on_paid_by_id"
  end

  create_table "item_participants", force: :cascade do |t|
    t.integer "expense_item_id", null: false
    t.integer "event_participant_id", null: false
    t.float "amount", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_participant_id"], name: "index_item_participants_on_event_participant_id"
    t.index ["expense_item_id"], name: "index_item_participants_on_expense_item_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "event_participants", "expense_events"
  add_foreign_key "event_participants", "users"
  add_foreign_key "expense_items", "event_participants", column: "paid_by_id"
  add_foreign_key "expense_items", "expense_events"
  add_foreign_key "item_participants", "event_participants"
  add_foreign_key "item_participants", "expense_items"
  add_foreign_key "sessions", "users"
end
