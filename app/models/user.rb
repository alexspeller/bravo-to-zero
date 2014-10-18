class User < ActiveRecord::Base
  validates :name, :email, :refresh_token, presence: true
  validates :email, email: true

  has_many :messages, dependent: :destroy

  def message_count
    messages.count
  end
end