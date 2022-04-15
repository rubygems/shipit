  # This migration comes from shipit (originally 20200706145406)
class AddReviewStacks < ActiveRecord::Migration[6.0]
  def change
    add_column :stacks, :provision_status, :string, limit: 191, null: false, default: :deprovisioned
    add_index :stacks, :provision_status

    add_column :stacks, :type, :string, limit: 191, default: "Shipit::Stack"
    add_index :stacks, :type

    add_column :stacks, :awaiting_provision, :boolean, null: false, default: false
    add_index :stacks, :awaiting_provision
  end
end
