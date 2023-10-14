FactoryBot.define do
  factory :room do
    capacity { 2 }
    price_per_night { 20.75 }
    description { 'this is our test room' }
  end
end
