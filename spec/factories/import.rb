# frozen_string_literal: true

FactoryBot.define do
  factory :import do
    status { 'processing' }
    error { '' }
    filename { "#{Faker::Alphanumeric.alphanumeric(number: 10)}.csv" }
    user { create :user }
  end
end
