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

ActiveRecord::Schema[7.1].define(version: 2026_04_24_192015) do
  create_table "achievements", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "icon"
    t.string "condition_type"
    t.integer "condition_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activity_executions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "point_activity_id", null: false
    t.datetime "executed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["point_activity_id"], name: "index_activity_executions_on_point_activity_id"
    t.index ["user_id"], name: "index_activity_executions_on_user_id"
  end

  create_table "activity_logs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "point_activity_id", null: false
    t.string "action_type"
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["point_activity_id"], name: "index_activity_logs_on_point_activity_id"
    t.index ["user_id"], name: "index_activity_logs_on_user_id"
  end

  create_table "activity_schedules", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "point_activity_id", null: false
    t.string "frequency"
    t.json "days_of_week"
    t.time "available_from"
    t.time "available_until"
    t.integer "estimated_minutes"
    t.integer "estimated_points"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["point_activity_id"], name: "index_activity_schedules_on_point_activity_id"
  end

  create_table "ai_advices", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "content"
    t.string "advice_type"
    t.datetime "generated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_ai_advices_on_user_id"
  end

  create_table "campaigns", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title"
    t.string "campaign_type"
    t.datetime "start_at"
    t.datetime "end_at"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_categories_on_code", unique: true
  end

  create_table "daily_tasks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "point_activity_id", null: false
    t.date "task_date", null: false
    t.boolean "completed", default: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["point_activity_id"], name: "index_daily_tasks_on_point_activity_id"
    t.index ["user_id", "task_date", "point_activity_id"], name: "idx_daily_tasks_uniqueness", unique: true
    t.index ["user_id"], name: "index_daily_tasks_on_user_id"
  end

  create_table "line_profiles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "line_user_id"
    t.string "display_name"
    t.string "picture_url"
    t.string "status_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["line_user_id"], name: "index_line_profiles_on_line_user_id", unique: true
    t.index ["user_id"], name: "index_line_profiles_on_user_id"
  end

  create_table "notification_logs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "notification_type"
    t.string "channel"
    t.string "status"
    t.text "content"
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notification_logs_on_user_id"
  end

  create_table "notification_settings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.boolean "morning_reminder", default: true
    t.time "morning_reminder_time", default: "2000-01-01 08:00:00"
    t.boolean "evening_summary", default: true
    t.time "evening_summary_time", default: "2000-01-01 21:00:00"
    t.boolean "campaign_alert", default: true
    t.boolean "achievement_alert", default: true
    t.boolean "streak_warning", default: true
    t.string "notification_channel", default: "line"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "reminder_hours"
    t.index ["user_id"], name: "index_notification_settings_on_user_id"
  end

  create_table "point_activities", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "point_activity_title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.text "detail_description"
    t.string "official_url"
    t.string "strategy_url"
    t.integer "parent_id"
    t.string "service_name"
    t.string "platform"
    t.string "content_category"
    t.string "frequency"
    t.integer "recommendation_level", default: 1
    t.bigint "service_id"
    t.bigint "category_id"
    t.string "major_item"
    t.string "small_item"
    t.integer "activity_type", default: 0
    t.integer "interval_seconds"
    t.integer "executions_per_reward", default: 1
    t.integer "reward_points", default: 1
    t.string "time_limit_modes"
    t.integer "daily_max_executions"
    t.integer "per_window_max_executions"
    t.json "custom_windows"
    t.index ["category_id"], name: "index_point_activities_on_category_id"
    t.index ["parent_id"], name: "index_point_activities_on_parent_id"
    t.index ["service_id"], name: "index_point_activities_on_service_id"
  end

  create_table "point_activity_gets", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "point_activity_id", null: false
    t.integer "get_point"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["point_activity_id"], name: "index_point_activity_gets_on_point_activity_id"
  end

  create_table "point_activity_targets", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "point_activity_id", null: false
    t.integer "target_point"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "year_month"
    t.float "priority_score"
    t.index ["point_activity_id"], name: "index_point_activity_targets_on_point_activity_id"
  end

  create_table "point_import_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "point_import_id", null: false
    t.bigint "point_activity_id", null: false
    t.string "category_name"
    t.string "description"
    t.integer "points"
    t.boolean "confirmed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["point_activity_id"], name: "index_point_import_items_on_point_activity_id"
    t.index ["point_import_id"], name: "index_point_import_items_on_point_import_id"
  end

  create_table "point_imports", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "status"
    t.json "raw_result"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_point_imports_on_user_id"
  end

  create_table "push_subscriptions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "endpoint"
    t.string "p256dh"
    t.string "auth"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_push_subscriptions_on_user_id"
  end

  create_table "services", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.string "platform"
    t.string "official_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "recommended_points"
    t.string "icon"
    t.index ["code"], name: "index_services_on_code", unique: true
  end

  create_table "settings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_achievements", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "achievement_id", null: false
    t.datetime "earned_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["achievement_id"], name: "index_user_achievements_on_achievement_id"
    t.index ["user_id", "achievement_id"], name: "index_user_achievements_on_user_id_and_achievement_id", unique: true
    t.index ["user_id"], name: "index_user_achievements_on_user_id"
  end

  create_table "user_streaks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "current_streak", default: 0
    t.integer "longest_streak", default: 0
    t.date "last_completed_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_streaks_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "google_token"
    t.string "google_refresh_token"
    t.datetime "google_token_expires_at"
    t.string "google_calendar_id"
    t.integer "selected_course"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activity_executions", "point_activities"
  add_foreign_key "activity_executions", "users"
  add_foreign_key "activity_logs", "point_activities"
  add_foreign_key "activity_logs", "users"
  add_foreign_key "activity_schedules", "point_activities"
  add_foreign_key "ai_advices", "users"
  add_foreign_key "daily_tasks", "point_activities"
  add_foreign_key "daily_tasks", "users"
  add_foreign_key "line_profiles", "users"
  add_foreign_key "notification_logs", "users"
  add_foreign_key "notification_settings", "users"
  add_foreign_key "point_activities", "categories"
  add_foreign_key "point_activities", "services"
  add_foreign_key "point_activity_gets", "point_activities"
  add_foreign_key "point_activity_targets", "point_activities"
  add_foreign_key "point_import_items", "point_activities"
  add_foreign_key "point_import_items", "point_imports"
  add_foreign_key "point_imports", "users"
  add_foreign_key "push_subscriptions", "users"
  add_foreign_key "user_achievements", "achievements"
  add_foreign_key "user_achievements", "users"
  add_foreign_key "user_streaks", "users"
end
