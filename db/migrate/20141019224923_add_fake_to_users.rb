class AddFakeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_fake, :boolean
  end
end
