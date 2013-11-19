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

ActiveRecord::Schema.define(version: 20131119014820) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: true do |t|
    t.integer  "customer_id"
    t.string   "status"
    t.string   "account_number"
    t.string   "account_nickname"
    t.integer  "display_position"
    t.integer  "institution_id"
    t.string   "description"
    t.decimal  "balance_amount"
    t.datetime "balance_date"
    t.datetime "last_txn_date"
    t.datetime "aggr_success_date"
    t.datetime "aggr_attempt_date"
    t.string   "aggr_status_code"
    t.string   "currency_code"
    t.integer  "institution_login_id"
    t.string   "banking_account_type"
    t.decimal  "available_balance_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounts", ["customer_id"], name: "index_accounts_on_customer_id", using: :btree
  add_index "accounts", ["institution_id"], name: "index_accounts_on_institution_id", using: :btree

  create_table "customers", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "customers", ["user_id"], name: "index_customers_on_user_id", using: :btree

  create_table "institutions", force: true do |t|
    t.string   "name"
    t.string   "home_url"
    t.string   "phone_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "list_items", force: true do |t|
    t.integer  "list_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lists", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lists", ["name", "user_id"], name: "index_lists_on_name_and_user_id", unique: true, using: :btree

  create_table "transactions", force: true do |t|
    t.integer  "account_id"
    t.string   "currency_type"
    t.string   "institution_transaction_id"
    t.string   "payee_name"
    t.datetime "posted_date"
    t.datetime "user_date"
    t.decimal  "amount"
    t.boolean  "pending"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transactions", ["account_id"], name: "index_transactions_on_account_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

end
