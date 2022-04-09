# frozen_string_literal: true

# This migration comes from shipit (originally 20200804144639)
class RenamePullRequestToMergeRequest < ActiveRecord::Migration[6.0]
  def change
    rename_table :pull_requests, :merge_requests
  end
end
