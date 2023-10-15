class RoomReservationAbility
  include CanCan::Ability
  def initialize(user)
    can :cancel, RoomReservation do |reservation|
      user.admin? || reservation.user == user
    end
  end
end