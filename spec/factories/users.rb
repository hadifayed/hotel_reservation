FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    name { 'test' }
    password { 'test1234' }
  end
end
