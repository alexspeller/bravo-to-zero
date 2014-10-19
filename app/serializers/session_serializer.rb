class SessionSerializer < ActiveModel::Serializer
  attributes :csrf_token, :pusher_key
  has_one :user

  def pusher_key
    ENV['BRAVO_PUSHER_KEY']
  end
end