class AddMessageTables < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :refresh_token
      t.string :image_url
      t.string :most_recent_message_id
    end

    add_index :users, :email

    create_table :messages do |t|
      t.belongs_to :user
      t.string :google_id
      t.text :snippet
      t.text :from
      t.text :to
      t.text :subject
      t.datetime :date
      t.string :thread_id
      t.integer :history_id
      t.text :labels, array: true, default: []
    end

    add_index :messages, [:user_id, :from]
    add_index :messages, [:user_id, :to]
    add_index :messages, [:user_id, :date]
  end
end
