# This migration comes from shipit_engine (originally 20150814182557)
class AddEnvToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :env, :text
  end
end
