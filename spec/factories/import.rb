FactoryBot.define do
    factory :import do
        status {"processing"}
        error {nil}
        filename {"#{Faker::Alphanumeric.alphanumeric(number: 10)}.csv" }
        user { create :user }
    end
  end
  