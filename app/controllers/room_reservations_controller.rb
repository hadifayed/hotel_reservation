class RoomReservationsController < ApplicationController
  before_action :authenticate_user!

  # POST /room_reservations
  def create
    reservation_creation_service = CreateReservationService.new(Room.find_by(id: room_reservation_params[:room_id]),
                                                                current_user,
                                                                room_reservation_params[:check_in],
                                                                room_reservation_params[:check_out])
    reservation_creation_service.create_reservation
    @reservation_record = reservation_creation_service.reservation
    if @reservation_record.persisted?
      render json: @reservation_record, status: :created
    else
      render json: @reservation_record.errors.full_messages, status: :unprocessable_entity
    end
  end

  # GET /room_reservations/within_range
  def within_range
    range_parser_service = RangeParserService.new(room_reservation_params)
    unless range_parser_service.parse_range
      render json: [I18n.t('room_reservation.invalid_range')], status: :bad_request
      return
    end

    render json: current_user.room_reservations.within_range(range_parser_service.range)
  end

  # POST /room_reservations/:id/cancel
  def cancel
    @reservation = current_user.room_reservations.find_by(id: params[:id])
    if @reservation
      if @reservation.update(status: RoomReservation.statuses[:canceled])
        render json: @reservation, status: :ok
      else
        render json: @reservation.errors, status: :unprocessable_entity
      end
    else
      render json: [I18n.t('room_reservation.reservation_not_found')], status: :bad_request
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def room_reservation_params
    params.require(:room_reservation).permit(:room_id, :check_in, :check_out)
  end
end
