# This migration comes from shipit_engine (originally 20151103144716)
class ConvertStacksLockReasonToText < ActiveRecord::Migration
  def change
    change_column :stacks, :lock_reason, :string, limit: 4096
  end
end
