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

ActiveRecord::Schema.define(version: 20170214043922) do

  create_table "api_clients", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.text     "permissions", limit: 65535
    t.integer  "creator_id"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "name",                      default: ""
    t.integer  "stack_id"
    t.index ["creator_id"], name: "index_api_clients_on_creator_id", using: :btree
  end

  create_table "commit_deployment_statuses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.integer  "commit_deployment_id"
    t.string   "status"
    t.integer  "github_id"
    t.string   "api_url"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["commit_deployment_id"], name: "index_commit_deployment_statuses_on_commit_deployment_id", using: :btree
  end

  create_table "commit_deployments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.integer  "commit_id"
    t.integer  "task_id"
    t.integer  "github_id"
    t.string   "api_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commit_id", "task_id"], name: "index_commit_deployments_on_commit_id_and_task_id", unique: true, using: :btree
    t.index ["task_id"], name: "index_commit_deployments_on_task_id", using: :btree
  end

  create_table "commits", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.integer  "stack_id",                                   null: false
    t.integer  "author_id",                                  null: false
    t.integer  "committer_id",                               null: false
    t.string   "sha",          limit: 40,                    null: false
    t.text     "message",      limit: 65535,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "detached",                   default: false, null: false
    t.datetime "authored_at",                                null: false
    t.datetime "committed_at",                               null: false
    t.integer  "additions"
    t.integer  "deletions"
    t.index ["author_id"], name: "index_commits_on_author_id", using: :btree
    t.index ["committer_id"], name: "index_commits_on_committer_id", using: :btree
    t.index ["created_at"], name: "index_commits_on_created_at", using: :btree
    t.index ["stack_id"], name: "index_commits_on_stack_id", using: :btree
  end

  create_table "deliveries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.integer  "hook_id",                                               null: false
    t.string   "status",           limit: 50,       default: "pending", null: false
    t.string   "url",              limit: 4096,                         null: false
    t.string   "content_type",                                          null: false
    t.string   "event",            limit: 50,                           null: false
    t.text     "payload",          limit: 16777215,                     null: false
    t.integer  "response_code"
    t.text     "response_headers", limit: 65535
    t.text     "response_body",    limit: 65535
    t.datetime "delivered_at"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.index ["created_at"], name: "index_deliveries_on_created_at", using: :btree
    t.index ["hook_id", "event", "status"], name: "index_deliveries_on_hook_id_and_event_and_status", using: :btree
    t.index ["status", "event"], name: "index_deliveries_on_status_and_event", using: :btree
  end

  create_table "github_hooks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.integer  "stack_id"
    t.integer  "github_id"
    t.string   "event",        limit: 50, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "secret"
    t.string   "api_url"
    t.string   "type"
    t.string   "organization", limit: 39
    t.index ["organization", "event"], name: "index_github_hooks_on_organization_and_event", unique: true, using: :btree
    t.index ["stack_id", "event"], name: "index_github_hooks_on_stack_id_and_event", unique: true, using: :btree
  end

  create_table "hooks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.integer  "stack_id"
    t.string   "delivery_url", limit: 4096,                  null: false
    t.string   "content_type", limit: 4,    default: "json", null: false
    t.string   "secret"
    t.string   "events",                    default: "",     null: false
    t.boolean  "insecure_ssl",              default: false,  null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.index ["stack_id"], name: "index_hooks_on_stack_id", using: :btree
  end

  create_table "memberships", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.integer  "team_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id", "user_id"], name: "index_memberships_on_team_id_and_user_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_memberships_on_user_id", using: :btree
  end

  create_table "output_chunks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.integer  "task_id"
    t.text     "text",       limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["task_id"], name: "index_output_chunks_on_task_id", using: :btree
  end

  create_table "stacks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.string   "repo_name",                         limit: 100,                          null: false
    t.string   "repo_owner",                        limit: 39,                           null: false
    t.string   "environment",                       limit: 50,    default: "production", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "branch",                                          default: "master",     null: false
    t.string   "deploy_url"
    t.string   "lock_reason",                       limit: 4096
    t.integer  "tasks_count",                                     default: 0,            null: false
    t.boolean  "continuous_deployment",                           default: false,        null: false
    t.integer  "undeployed_commits_count",                        default: 0,            null: false
    t.text     "cached_deploy_spec",                limit: 65535
    t.integer  "lock_author_id"
    t.boolean  "ignore_ci"
    t.datetime "inaccessible_since"
    t.integer  "estimated_deploy_duration",                       default: 1,            null: false
    t.datetime "continuous_delivery_delayed_since"
    t.datetime "locked_since"
    t.index ["repo_owner", "repo_name", "environment"], name: "stack_unicity", unique: true, using: :btree
  end

  create_table "statuses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.string   "state"
    t.string   "target_url"
    t.text     "description", limit: 65535
    t.string   "context",                   default: "default", null: false
    t.integer  "commit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "stack_id",                                      null: false
    t.index ["commit_id"], name: "index_statuses_on_commit_id", using: :btree
  end

  create_table "tasks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.integer  "stack_id",                                                   null: false
    t.integer  "since_commit_id",                                            null: false
    t.integer  "until_commit_id",                                            null: false
    t.string   "status",                limit: 10,       default: "pending", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "rolled_up",                              default: false,     null: false
    t.string   "type",                  limit: 20
    t.integer  "parent_id"
    t.integer  "additions",                              default: 0
    t.integer  "deletions",                              default: 0
    t.text     "definition",            limit: 65535
    t.binary   "gzip_output",           limit: 16777215
    t.boolean  "rollback_once_aborted",                  default: false,     null: false
    t.text     "env",                   limit: 65535
    t.integer  "confirmations",                          default: 0,         null: false
    t.boolean  "allow_concurrency",                      default: false,     null: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.index ["rolled_up", "created_at", "status"], name: "index_tasks_on_rolled_up_and_created_at_and_status", using: :btree
    t.index ["since_commit_id"], name: "index_tasks_on_since_commit_id", using: :btree
    t.index ["stack_id", "allow_concurrency", "status"], name: "index_active_tasks", using: :btree
    t.index ["type", "stack_id", "parent_id"], name: "index_tasks_by_stack_and_parent", using: :btree
    t.index ["type", "stack_id", "status"], name: "index_tasks_by_stack_and_status", using: :btree
    t.index ["until_commit_id"], name: "index_tasks_on_until_commit_id", using: :btree
    t.index ["user_id"], name: "index_tasks_on_user_id", using: :btree
  end

  create_table "teams", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.integer  "github_id"
    t.string   "api_url"
    t.string   "slug",         limit: 50
    t.string   "name"
    t.string   "organization", limit: 39
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["organization", "slug"], name: "index_teams_on_organization_and_slug", unique: true, using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin" do |t|
    t.integer  "github_id"
    t.string   "name",                                        null: false
    t.string   "email"
    t.string   "login",                            limit: 39
    t.string   "api_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_url"
    t.string   "encrypted_github_access_token"
    t.string   "encrypted_github_access_token_iv"
    t.index ["login"], name: "index_users_on_login", using: :btree
  end

  add_foreign_key "commit_deployment_statuses", "commit_deployments"
  add_foreign_key "commit_deployments", "commits"
  add_foreign_key "commit_deployments", "tasks"
  add_foreign_key "memberships", "teams"
  add_foreign_key "memberships", "users"
end
