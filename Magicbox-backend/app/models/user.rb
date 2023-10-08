class User < ApplicationRecord
  attr_encrypted :github_token, key: ENV.fetch('ENCRYPTION_KEY', nil).byteslice(0..31)
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
