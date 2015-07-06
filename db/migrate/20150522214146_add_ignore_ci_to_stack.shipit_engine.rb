# This migration comes from shipit_engine (originally 20150518214944)
class AddIgnoreCiToStack < ActiveRecord::Migration
  def change
    add_column :stacks, :ignore_ci, :boolean
  end
end
