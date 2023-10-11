class Room < ApplicationRecord
	has_many :room_reservations, dependent: :destroy

	validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }
	validates :price_per_night, presence: true, numericality: { greater_than: 0 }

	def locking_enabled?
		super && persisted? && reservation_count_changed?
	end
end
