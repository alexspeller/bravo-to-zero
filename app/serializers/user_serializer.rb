class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :image_url, :message_count
end