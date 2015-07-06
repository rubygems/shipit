# This migration comes from shipit_engine (originally 20150515190352)
class AddOutputColumnToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :gzip_output, :binary, limit: 16777215
  end
end
