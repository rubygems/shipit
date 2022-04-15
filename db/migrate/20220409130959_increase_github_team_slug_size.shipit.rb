# This migration comes from shipit (originally 20211103154121)
class IncreaseGithubTeamSlugSize < ActiveRecord::Migration[6.1]
  def change
    change_column :teams, :slug, :string, limit: 191, null: true
  end
end
