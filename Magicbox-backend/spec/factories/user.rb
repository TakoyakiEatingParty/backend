FactoryBot.define do
  factory :user do
    provider { 'github' }
    sequence(:uid) { |n| "uid#{n}" }
    sequence(:name) { |n| "name#{n}" }
    sequence(:image_url) { |n| "http://example.com/image#{n}.png" }
  end
end
