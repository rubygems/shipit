# frozen_string_literal: true
# This migration comes from shipit (originally 20200813134712)
class RecreateShipitPullRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :pull_requests do |t|
      t.references :stack, null: false
      t.integer :number, null: false
      t.string :title, limit: 191
      t.integer :github_id, limit: 8
      t.string :api_url, limit: 191
      t.string :state, limit: 191
      t.integer :additions, null: false, default: 0
      t.integer :deletions, null: false, default: 0
      t.integer :user_id
      t.text :labels
      t.references :head
      t.timestamps

      t.index [:stack_id, :number], unique: true
      t.index [:stack_id, :github_id], unique: true
    end
  end
end
