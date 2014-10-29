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

ActiveRecord::Schema.define(version: 20141017123550) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "card_metas", force: true do |t|
    t.integer  "card_id"
    t.datetime "last_evaluation_date"
    t.datetime "next_evaluation_date"
    t.integer  "current_successful_timespan"
    t.integer  "ever_successful_timespan"
    t.integer  "success_count_since_ever"
    t.integer  "fail_count_since_ever"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "previous"
    t.integer  "success_count_since_record"
    t.integer  "fail_count_since_record"
    t.integer  "record_timespan"
    t.integer  "current_timespan"
    t.integer  "current_success_count"
    t.datetime "reverse_last_evaluation_date"
  end

  add_index "card_metas", ["card_id"], name: "index_card_metas_on_card_id", using: :btree
  add_index "card_metas", ["last_evaluation_date"], name: "index_card_metas_on_last_evaluation_date", using: :btree
  add_index "card_metas", ["next_evaluation_date"], name: "index_card_metas_on_next_evaluation_date", using: :btree

  create_table "cards", force: true do |t|
    t.integer  "user_id"
    t.integer  "list_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "evaluable_id"
    t.string   "evaluable_type"
  end

  add_index "cards", ["evaluable_id", "evaluable_type"], name: "index_cards_on_evaluable_id_and_evaluable_type", unique: true, using: :btree
  add_index "cards", ["list_id"], name: "index_cards_on_list_id", using: :btree
  add_index "cards", ["user_id"], name: "index_cards_on_user_id", using: :btree

  create_table "evaluations", force: true do |t|
    t.integer  "card_id"
    t.boolean  "result"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "evaluations", ["card_id"], name: "index_evaluations_on_card_id", using: :btree
  add_index "evaluations", ["created_at"], name: "index_evaluations_on_created_at", using: :btree

  create_table "lists", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "chronos_success_min_tspan"
    t.integer  "chronos_capacity_volume"
    t.integer  "chronos_capacity_tspan"
    t.boolean  "reverse"
    t.integer  "review_mail_recurrency"
  end

  add_index "lists", ["user_id", "name"], name: "index_lists_on_user_id_and_name", unique: true, using: :btree
  add_index "lists", ["user_id"], name: "index_lists_on_user_id", using: :btree

  create_table "signup_attempts", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "invite_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
    t.text     "guide"
    t.string   "email_confirmation_token"
    t.datetime "email_confirmation_last_sent_date"
    t.boolean  "email_confirmed",                   default: false
    t.string   "password_reset_token"
    t.datetime "password_reset_last_sent_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

  create_table "word_reverses", force: true do |t|
    t.integer "word_id"
  end

  add_index "word_reverses", ["word_id"], name: "index_word_reverses_on_word_id", using: :btree

  create_table "words", force: true do |t|
    t.text     "content"
    t.text     "tip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
