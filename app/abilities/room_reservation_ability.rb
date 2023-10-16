class RoomReservationAbility
  include CanCan::Ability
  def initialize(user)
    can :cancel, RoomReservation do |reservation|
      user.admin? || reservation.user == user
    end

    can [:within_range, :create], User do |selected_user|
      user.admin? || selected_user == user
    end
  end
end