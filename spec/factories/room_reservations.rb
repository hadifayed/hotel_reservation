FactoryBot.define do
  factory :room_reservation do
    user
    room
    check_in { Date.current + 1.days }
    check_out { Date.current + 3.days }
  end
end
