class User < ActiveRecord::Base
  validates :name, :email, :refresh_token, presence: true
  validates :email, email: true

  has_many :messages, dependent: :destroy

  def message_count
    messages.count
  end

  def push event, data={}
    Pusher[push_channel].trigger event, data
  end

  def push_channel
    "private-user_#{id}"
  end
end