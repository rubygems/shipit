# This migration comes from shipit_engine (originally 20150630154640)
class AddInaccessibleSinceToStacks < ActiveRecord::Migration[4.2]
  def change
    add_column :stacks, :inaccessible_since, :datetime, default: nil
  end
end
