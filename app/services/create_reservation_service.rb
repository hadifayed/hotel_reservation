class CreateReservationService
  attr_reader :reservation
  def initialize(room, user, check_in, check_out)
    @room = room
    @user = user
    @check_in = check_in
    @check_out = check_out
    @reservation = RoomReservation.new(room: @room, user: @user, check_in: @check_in, check_out: @check_out)
  end

  def create_reservation
    reservation_not_created = true
    while reservation_not_created
      begin
        ActiveRecord::Base.transaction do
          reservation_not_created = false
          @room.update(reservation_count: (@room.reservation_count + 1)) if @reservation.save
        end
      rescue ActiveRecord::StaleObjectError
        reservation_not_created = true
        @room.reload
      end
    end    
  end
end