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

ActiveRecord::Schema[8.0].define(version: 2025_03_26_064429) do
  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.datetime "posted_date"
    t.integer "view_count"
    t.string "author_name"
    t.string "author_id"
    t.string "author_email"
    t.string "cid"
    t.string "gid"
    t.string "bid"
    t.boolean "is_notice"
    t.text "attachment_urls"
    t.text "attachment_names"
    t.string "source_url"
    t.datetime "scraped_at"
    t.datetime "last_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
