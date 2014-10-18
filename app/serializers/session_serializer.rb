class SessionSerializer < ActiveModel::Serializer
  attributes :csrf_token
  has_one :user
end