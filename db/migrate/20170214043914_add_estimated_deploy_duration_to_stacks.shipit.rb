# This migration comes from shipit (originally 20160502150713)
class AddEstimatedDeployDurationToStacks < ActiveRecord::Migration
  def change
    add_column :stacks, :estimated_deploy_duration, :integer, null: false, default: 1
  end
end
