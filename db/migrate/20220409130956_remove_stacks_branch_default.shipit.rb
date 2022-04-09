# This migration comes from shipit (originally 20210325194053)
class RemoveStacksBranchDefault < ActiveRecord::Migration[6.1]
  def change
    change_column_default(:stacks, :branch, from: 'master', to: nil)
  end
end
