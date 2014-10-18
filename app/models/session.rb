class Session
  include ActiveModel::SerializerSupport
  extend ActiveModel::Naming

  attr_accessor :user, :csrf_token

  def initialize csrf_token, user
    @csrf_token, @user = csrf_token, user
  end
end
