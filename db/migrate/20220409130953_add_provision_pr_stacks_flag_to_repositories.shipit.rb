# This migration comes from shipit (originally 20201001125502)
class AddProvisionPrStacksFlagToRepositories < ActiveRecord::Migration[6.0]
  def change
    add_column :repositories, :review_stacks_enabled, :boolean, default: false
    add_column :repositories, :provisioning_behavior, :string, limit: 191, default: :allow_all
    add_column :repositories, :provisioning_label_name, :string, limit: 191
  end
end
