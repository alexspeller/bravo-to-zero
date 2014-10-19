class AddSyncToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_syncing, :boolean
  end
end
