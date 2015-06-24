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

ActiveRecord::Schema.define(version: 20150423151654) do

  create_table "addresses", force: true do |t|
    t.string   "company_name"
    t.string   "contact_name"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string "state"
    t.string   "zipcode"
    t.string   "phone"
    t.string   "fax"
    t.string   "email"
    t.datetime "close_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "location_type"
    t.integer "address_state", default: 0, null: false
  end

  create_table "carriers", force: true do |t|
    t.string   "name"
    t.string   "carrier_key"
    t.string   "balanced_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "configuration_items", force: true do |t|
    t.string "configuration_key", null: false
    t.string "configuration_value", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "configuration_items", ["configuration_key"], name: "index_configuration_items_on_configuration_key", unique: true, using: :btree

  create_table "credit_applications", force: true do |t|
    t.string   "company_name",                                                 null: false
    t.string   "alternate_name"
    t.string   "contact_name",                                                 null: false
    t.string   "title"
    t.string   "phone_number",                                                 null: false
    t.string   "company_address_1",                                            null: false
    t.string   "company_address_2"
    t.string   "city",                                                         null: false
    t.string   "state",                                                        null: false
    t.string   "zip_code",                                                     null: false
    t.integer  "status",                                         default: 0,   null: false
    t.integer  "user_id",                                                      null: false
    t.text     "message"
    t.decimal  "requested_credit_line", precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "approved_credit_line"
    t.decimal  "available_credit",      precision: 10, scale: 2, default: 0.0
  end

  create_table "credit_events", force: true do |t|
    t.integer  "credit_application_id",                          null: false
    t.integer  "shipment_id",                                    null: false
    t.integer  "status",                                         null: false
    t.decimal  "amount",                precision: 10, scale: 2, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dictionaries", force: true do |t|
    t.string   "name",       null: false
    t.string   "code",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dictionary_entries", force: true do |t|
    t.string   "name",          null: false
    t.string   "key",           null: false
    t.integer  "dictionary_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "freight_items", force: true do |t|
    t.integer  "shipment_id",                                                 null: false
    t.decimal  "weight",             precision: 10, scale: 2,                 null: false
    t.string   "weight_unit",                                                 null: false
    t.string   "freight_class_code"
    t.string   "freight_type",                                                null: false
    t.integer  "quantity",                                    default: 1,     null: false
    t.boolean  "hazardous",                                   default: false, null: false
    t.string   "nmfc"
    t.string   "nmfc_sub"
    t.string   "purchase_order"
    t.string   "bol_description"
    t.string   "freight_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "dim_length",         precision: 10, scale: 2
    t.decimal  "dim_width",          precision: 10, scale: 2
    t.decimal  "dim_height",         precision: 10, scale: 2
    t.decimal  "estimated_value",    precision: 10, scale: 2
    t.text     "accessorials"
    t.integer  "piece_count",                                 default: 1
  end

  add_index "freight_items", ["shipment_id"], name: "index_freight_items_on_shipment_id", using: :btree

  create_table "payment_methods", force: true do |t|
    t.integer  "user_id",                              null: false
    t.integer  "payment_method_type",                  null: false
    t.string   "rebill_id"
    t.boolean  "saved",                 default: true, null: false
    t.integer  "cc_expiration_month"
    t.integer  "cc_expiration_year"
    t.integer  "cc_last_four"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "credit_application_id"
  end

  create_table "payment_splits", force: true do |t|
    t.integer  "payment_id",                          null: false
    t.decimal  "amount",     precision: 10, scale: 2, null: false
    t.integer  "fund",                                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payments", force: true do |t|
    t.integer  "shipment_id",                                null: false
    t.integer  "payment_method_id",                          null: false
    t.integer  "status",                                     null: false
    t.integer  "error_code"
    t.string   "error_message"
    t.string   "transaction_id"
    t.string   "rebill_token"
    t.decimal  "amount",            precision: 10, scale: 2, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shipment_events", force: true do |t|
    t.integer  "shipment_id"
    t.string   "status_key"
    t.string   "message"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shipment_events", ["shipment_id"], name: "index_shipment_events_on_shipment_id", using: :btree

  create_table "shipments", force: true do |t|
    t.integer  "origin_address_id"
    t.integer  "destination_address_id"
    t.datetime "pickup_date"
    t.integer  "user_id"
    t.string   "hazardous_materials_phone"
    t.string   "special_instructions"
    t.integer  "status",                                             default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "quote_payload"
    t.string   "error_message"
    t.string   "selected_quote"
    t.text     "accessorials"
    t.string   "user_token"
    t.string   "bol"
    t.string   "bol_file"
    t.datetime "quote_time"
    t.integer  "payment_method_id"
    t.string "stripe_transaction_id"
    t.decimal  "selected_quote_price",      precision: 10, scale: 2
    t.string   "selected_carrier"
    t.text     "extended_error_message"
    t.string   "hold_id"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "location"
    t.string   "ships_where"
    t.integer  "industry_type"
    t.integer  "naics_code_id"
    t.integer  "sic_code_id"
    t.boolean  "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "stripe_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end