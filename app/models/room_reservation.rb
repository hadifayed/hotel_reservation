class RoomReservation < ApplicationRecord
  enum status: { pending: 1, canceled: 2 }

  belongs_to :room
  belongs_to :user

  validates :check_in, :check_out, presence: true
  validate :check_in_and_check_out_are_not_in_the_past
  validate :check_out_is_after_check_in
  validate :room_is_available

  scope :within_range, ->(range) { where(check_in: range).or(where(check_out: range)) }

  private

  def should_not_validate_check_in_and_check_out?
    return true if check_in.blank? || check_out.blank? || !check_in_changed? || !check_out_changed?

    false
  end

  def check_in_and_check_out_are_not_in_the_past
    return if should_not_validate_check_in_and_check_out?

    errors.add(:check_out, :past_error) if Date.current > check_out
    errors.add(:check_in, :past_error) if Date.current > check_in
  end

  def check_out_is_after_check_in
    return if should_not_validate_check_in_and_check_out?

    errors.add(:check_out, :after_check_in) if check_out < check_in
  end

  def room_is_available
    return if should_not_validate_check_in_and_check_out?

    RoomReservation.pending.where(room_id: room_id).each do |reservation|
      check_in_within_reserved_period = (reservation.check_in..reservation.check_out) === check_in
      check_out_within_reserved_period = (reservation.check_in..reservation.check_out) === check_out

      errors.add(:room, :not_available) if check_in_within_reserved_period || check_out_within_reserved_period
    end
  end
end
