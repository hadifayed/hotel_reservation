require "rails_helper"

RSpec.describe RoomReservationsController, type: :routing do
  describe "routing" do
    it { should route(:post, '/room_reservations').to(action: :create) }
    it { should route(:get, '/room_reservations/within_range').to(action: :within_range) }
    it { should route(:patch, '/room_reservations/1/cancel').to(action: :cancel, id: 1) }
  end
end
