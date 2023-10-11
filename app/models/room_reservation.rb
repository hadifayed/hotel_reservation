class RoomReservation < ApplicationRecord
  enum status: { pending: 1, canceled: 2 }

  belongs_to :room
  belongs_to :user

  validates :check_in, :check_out, presence: true
  validate :check_in_and_check_out_are_not_in_the_past
  validate :check_out_is_after_check_in
  validate :room_is_available

  private

  def check_in_and_check_out_are_not_in_the_past
    return if check_in.blank? || check_out.blank?

    errors.add(:check_out, :past_error) if Date.current > check_out
    errors.add(:check_in, :past_error) if Date.current > check_in
  end

  def check_out_is_after_check_in
    return if check_in.blank? || check_out.blank?

    if check_out < check_in
      errors.add(:check_out, :after_check_in)
    end
  end

  def room_is_available
    return if check_in.blank? || check_out.blank?

    RoomReservation.pending.where(room_id: room_id).each do |reservation|
      check_in_within_reserved_period = (reservation.check_in..reservation.check_out) === check_in
      check_out_within_reserved_period = (reservation.check_in..reservation.check_out) === check_out
      if check_in_within_reserved_period || check_out_within_reserved_period
        errors.add(:room, :not_available)
      end
    end
  end
end
