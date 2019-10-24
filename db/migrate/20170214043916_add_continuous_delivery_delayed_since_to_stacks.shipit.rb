# This migration comes from shipit (originally 20160802092812)
class AddContinuousDeliveryDelayedSinceToStacks < ActiveRecord::Migration[4.2]
  def change
    add_column :stacks, :continuous_delivery_delayed_since, :datetime, null: true
  end
end
