FactoryBot.define do
  factory :user do
    sequence(:email, (User.count > 0 ? (User.last.email.split('@').first.to_i + 1) : 1)) { |n| "#{n}@factory.com" }
    name { 'test' }
    password { 'test1234' }
  end
end
