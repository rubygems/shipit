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

ActiveRecord::Schema.define(version: 20181014202523) do

  create_table "api_clients", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.text "permissions", limit: 16777215
    t.integer "creator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", default: ""
    t.integer "stack_id"
    t.index ["creator_id"], name: "index_api_clients_on_creator_id"
  end

  create_table "commit_deployment_statuses", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.integer "commit_deployment_id"
    t.string "status"
    t.integer "github_id"
    t.string "api_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commit_deployment_id"], name: "index_commit_deployment_statuses_on_commit_deployment_id"
  end

  create_table "commit_deployments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.integer "commit_id"
    t.integer "task_id"
    t.integer "github_id"
    t.string "api_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commit_id", "task_id"], name: "index_commit_deployments_on_commit_id_and_task_id", unique: true
    t.index ["task_id"], name: "index_commit_deployments_on_task_id"
  end

  create_table "commits", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.integer "stack_id", null: false
    t.integer "author_id", null: false
    t.integer "committer_id", null: false
    t.string "sha", limit: 40, null: false
    t.text "message", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "detached", default: false, null: false
    t.datetime "authored_at", null: false
    t.datetime "committed_at", null: false
    t.integer "additions"
    t.integer "deletions"
    t.integer "pull_request_number"
    t.string "pull_request_title", limit: 1024
    t.integer "pull_request_id"
    t.boolean "locked", default: false, null: false
    t.index ["author_id"], name: "index_commits_on_author_id"
    t.index ["committer_id"], name: "index_commits_on_committer_id"
    t.index ["created_at"], name: "index_commits_on_created_at"
    t.index ["sha", "stack_id"], name: "index_commits_on_sha_and_stack_id", unique: true
    t.index ["stack_id"], name: "index_commits_on_stack_id"
  end

  create_table "deliveries", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.integer "hook_id", null: false
    t.string "status", limit: 50, default: "pending", null: false
    t.string "url", limit: 4096, null: false
    t.string "content_type", null: false
    t.string "event", limit: 50, null: false
    t.text "payload", limit: 4294967295, null: false
    t.integer "response_code"
    t.text "response_headers", limit: 16777215
    t.text "response_body", limit: 16777215
    t.datetime "delivered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hook_id", "event", "status"], name: "index_deliveries_on_hook_id_and_event_and_status"
    t.index ["hook_id", "status"], name: "index_deliveries_on_hook_id_and_status"
  end

  create_table "github_hooks", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.integer "stack_id"
    t.integer "github_id"
    t.string "event", limit: 50, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "secret"
    t.string "api_url"
    t.string "type"
    t.string "organization", limit: 39
    t.index ["organization", "event"], name: "index_github_hooks_on_organization_and_event", unique: true
    t.index ["stack_id", "event"], name: "index_github_hooks_on_stack_id_and_event", unique: true
  end

  create_table "hooks", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.integer "stack_id"
    t.string "delivery_url", limit: 4096, null: false
    t.string "content_type", limit: 4, default: "json", null: false
    t.string "secret"
    t.string "events", default: "", null: false
    t.boolean "insecure_ssl", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stack_id"], name: "index_hooks_on_stack_id"
  end

  create_table "memberships", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.integer "team_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id", "user_id"], name: "index_memberships_on_team_id_and_user_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "output_chunks", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.integer "task_id"
    t.text "text", limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["task_id"], name: "index_output_chunks_on_task_id"
  end

  create_table "pull_requests", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.integer "stack_id", null: false
    t.integer "number", null: false
    t.string "title", limit: 256
    t.bigint "github_id"
    t.string "api_url", limit: 1024
    t.string "state"
    t.integer "head_id"
    t.boolean "mergeable"
    t.integer "additions", default: 0, null: false
    t.integer "deletions", default: 0, null: false
    t.string "merge_status", limit: 30, null: false
    t.string "rejection_reason"
    t.datetime "merge_requested_at", null: false
    t.integer "merge_requested_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "branch"
    t.datetime "revalidated_at"
    t.datetime "merged_at"
    t.string "base_ref", limit: 1024
    t.integer "base_commit_id"
    t.index ["base_commit_id"], name: "fk_rails_eda2bf836a"
    t.index ["head_id"], name: "index_pull_requests_on_head_id"
    t.index ["merge_requested_by_id"], name: "index_pull_requests_on_merge_requested_by_id"
    t.index ["merge_status"], name: "index_pull_requests_on_merge_status"
    t.index ["stack_id", "github_id"], name: "index_pull_requests_on_stack_id_and_github_id", unique: true
    t.index ["stack_id", "merge_status"], name: "index_pull_requests_on_stack_id_and_merge_status"
    t.index ["stack_id", "number"], name: "index_pull_requests_on_stack_id_and_number", unique: true
    t.index ["stack_id"], name: "index_pull_requests_on_stack_id"
  end

  create_table "stacks", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.string "repo_name", limit: 100, null: false
    t.string "repo_owner", limit: 39, null: false
    t.string "environment", limit: 50, default: "production", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "branch", default: "master", null: false
    t.string "deploy_url"
    t.string "lock_reason", limit: 4096
    t.integer "tasks_count", default: 0, null: false
    t.boolean "continuous_deployment", default: false, null: false
    t.integer "undeployed_commits_count", default: 0, null: false
    t.text "cached_deploy_spec", limit: 16777215
    t.integer "lock_author_id"
    t.boolean "ignore_ci"
    t.datetime "inaccessible_since"
    t.integer "estimated_deploy_duration", default: 1, null: false
    t.datetime "continuous_delivery_delayed_since"
    t.datetime "locked_since"
    t.boolean "merge_queue_enabled", default: false, null: false
    t.datetime "last_deployed_at"
    t.index ["repo_owner", "repo_name", "environment"], name: "stack_unicity", unique: true
  end

  create_table "statuses", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.string "state"
    t.string "target_url"
    t.text "description", limit: 16777215
    t.string "context", default: "default", null: false
    t.integer "commit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "stack_id", null: false
    t.index ["commit_id"], name: "index_statuses_on_commit_id"
  end

  create_table "tasks", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.integer "stack_id", null: false
    t.integer "since_commit_id", null: false
    t.integer "until_commit_id", null: false
    t.string "status", limit: 10, default: "pending", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.boolean "rolled_up", default: false, null: false
    t.string "type", limit: 20
    t.integer "parent_id"
    t.integer "additions", default: 0
    t.integer "deletions", default: 0
    t.text "definition", limit: 16777215
    t.binary "gzip_output", limit: 16777215
    t.boolean "rollback_once_aborted", default: false, null: false
    t.text "env", limit: 16777215
    t.integer "confirmations", default: 0, null: false
    t.boolean "allow_concurrency", default: false, null: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.boolean "ignored_safeties", default: false, null: false
    t.integer "aborted_by_id"
    t.index ["rolled_up", "created_at", "status"], name: "index_tasks_on_rolled_up_and_created_at_and_status"
    t.index ["since_commit_id"], name: "index_tasks_on_since_commit_id"
    t.index ["stack_id", "allow_concurrency", "status"], name: "index_active_tasks"
    t.index ["stack_id", "allow_concurrency"], name: "index_tasks_on_stack_id_and_allow_concurrency"
    t.index ["stack_id", "status", "type"], name: "index_tasks_by_stack_and_status"
    t.index ["type", "stack_id", "parent_id"], name: "index_tasks_by_stack_and_parent"
    t.index ["until_commit_id"], name: "index_tasks_on_until_commit_id"
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "teams", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.integer "github_id"
    t.string "api_url"
    t.string "slug", limit: 50
    t.string "name"
    t.string "organization", limit: 39
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization", "slug"], name: "index_teams_on_organization_and_slug", unique: true
  end

  create_table "users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.integer "github_id"
    t.string "name", null: false
    t.string "email"
    t.string "login", limit: 39
    t.string "api_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "avatar_url"
    t.string "encrypted_github_access_token"
    t.string "encrypted_github_access_token_iv"
    t.index ["github_id"], name: "index_users_on_github_id"
    t.index ["login"], name: "index_users_on_login"
    t.index ["updated_at"], name: "index_users_on_updated_at"
  end

  add_foreign_key "commit_deployment_statuses", "commit_deployments"
  add_foreign_key "commit_deployments", "commits"
  add_foreign_key "commit_deployments", "tasks"
  add_foreign_key "memberships", "teams"
  add_foreign_key "memberships", "users"
  add_foreign_key "pull_requests", "commits", column: "base_commit_id"
  add_foreign_key "pull_requests", "commits", column: "head_id"
  add_foreign_key "pull_requests", "stacks"
  add_foreign_key "pull_requests", "users", column: "merge_requested_by_id"
end
