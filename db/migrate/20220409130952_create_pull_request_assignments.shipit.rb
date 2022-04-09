# This migration comes from shipit (originally 20200813194056)
class CreatePullRequestAssignments < ActiveRecord::Migration[6.0]
  def change
    create_table :pull_request_assignments do |t|
      t.references :pull_request
      t.references :user
    end
  end
end
