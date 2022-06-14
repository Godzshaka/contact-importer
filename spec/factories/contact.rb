
FactoryBot.define do
  credit_card = Faker::Finance.credit_card(:mastercard)
    factory :contact do
        name { 'tester' }
        date_of_birth { Time.now-20.years }
        phone { Faker::Base.numerify('(+##) ###-###-##-##').to_s }
        address { Faker::Address.street_address }
        credit_card { credit_card }
        email { Faker::Internet.email }
        user { create :user }
        import { create :import }
        card_last_digits {credit_card[-4..-1]}
        card_number_length { credit_card.length }
        franchise { 'mastercard' }
    end
  end
  