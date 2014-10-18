class Message < ActiveRecord::Base
  belongs_to :user

  validates :google_id, presence: true, uniqueness: true

  validates :from, :to, :subject, :date, :thread_id, :history_id, presence: true
end