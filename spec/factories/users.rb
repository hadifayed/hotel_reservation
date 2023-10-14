FactoryBot.define do
  factory :user do
    sequence(:email, User.count) { |n| "email#{n}@factory.com" }
    name { 'test' }
    password { 'test1234' }
  end
end
