FactoryBot.define do
  factory :user do
    sequence(:email, User.count) { |n| "email#{n}@factory.com" }
    name { 'test' }
  end
end
