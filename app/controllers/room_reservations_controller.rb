class RoomReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, except: :cancel

  # POST /room_reservations
  def create
    authorize! :create, @user
    reservation_creation_service = CreateReservationService.new(Room.find(room_reservation_params[:room_id]),
                                                                @user,
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
    authorize! :within_range, @user
    range_parser_service = RangeParserService.new(room_reservation_params)
    unless range_parser_service.parse_range
      render json: [I18n.t('room_reservation.invalid_range')], status: :bad_request
      return
    end
    render json: @user.room_reservations.within_range(range_parser_service.range)
  end

  # PATCH /room_reservations/:id/cancel
  def cancel
    reservation = RoomReservation.find(params[:id])
    authorize! :cancel, reservation.user
    if reservation.update(status: RoomReservation.statuses[:canceled])
      render json: reservation, status: :ok
    else
      render json: reservation.errors, status: :unprocessable_entity
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def room_reservation_params
    params.require(:room_reservation).permit(:room_id, :check_in, :check_out, :user_id)
  end

  def current_ability
    @current_ability ||= RoomReservationAbility.new(current_user)
  end

  def set_user
    if room_reservation_params[:user_id].present?
      @user = User.find(room_reservation_params[:user_id])
    else
      @user = current_user
    end
  end
end
