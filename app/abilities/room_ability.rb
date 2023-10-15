class RoomAbility
  include CanCan::Ability
  def initialize(user)
    can :index, Room
    return unless user.admin?
    can [:create, :update], Room
  end
end