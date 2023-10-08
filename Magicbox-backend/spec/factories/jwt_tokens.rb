FactoryBot.define do
  factory :jwt_token do
    jti { SecureRandom.uuid }
    exp { 1.week.from_now }
  end
end
