# This migration comes from shipit (originally 20191219205202)
class AddArchivedSinceToStacks < ActiveRecord::Migration[6.0]
  def change
    add_column :stacks, :archived_since, :datetime
    add_index :stacks, :archived_since
  end
end
