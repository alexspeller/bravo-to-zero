class Message < ActiveRecord::Base
  belongs_to :user

  validates :google_id, presence: true, uniqueness: true

  validates :from, :to, :subject, :date, presence: true
end