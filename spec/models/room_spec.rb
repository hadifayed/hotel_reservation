require 'rails_helper'

RSpec.describe Room, type: :model do
  describe 'Associations' do
    it { is_expected.to have_many(:room_reservations) }
  end

  describe 'Validations' do
    context 'capacity' do
      it { is_expected.to validate_presence_of(:capacity) }
      it { is_expected.to validate_numericality_of(:capacity).only_integer.is_greater_than(0) }
    end

    context 'price_per_night' do
      it { is_expected.to validate_presence_of(:price_per_night) }
      it { is_expected.to validate_numericality_of(:price_per_night).is_greater_than(0) }
    end
  end

  describe 'Locking' do
    before :all do
      @room = FactoryBot.create(:room)
    end

    it 'enables locking only when reservation_count field is updated' do
      expect { @room.update(reservation_count: (@room.reservation_count + 1)) }.to change(@room, :lock_version).by(1)
    end

    { capacity: 3, price_per_night: '10.75', description: 'Our new description'}.each do |field, value|
      it "does not enable locking when #{field} field is updated" do
        expect { @room.update(field => value) }.not_to change(@room, :lock_version)
      end
    end
  end
end
