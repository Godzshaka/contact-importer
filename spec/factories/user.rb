FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.uuid }
  end
end
