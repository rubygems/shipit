# This migration comes from shipit (originally 20160122165559)
class RenameHooksUrlInDeliveryUrl < ActiveRecord::Migration[4.2]
  def change
    rename_column :hooks, :url, :delivery_url
  end
end
