class User < ApplicationRecord
  def self.find_or_create_from_auth_hash!(auth_hash)
    uid = auth_hash[:uid]
    nickname = auth_hash[:name]
    image_url = auth_hash[:image_url]
    User.find_or_create_by!(provider: 'github', uid: uid) do |user|
      user.provider = 'github'
      user.uid = uid
      user.name = nickname
      user.image_url = image_url
    end
  end
end
