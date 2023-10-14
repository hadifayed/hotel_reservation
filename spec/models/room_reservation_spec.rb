require 'rails_helper'

RSpec.describe RoomReservation, type: :model do
  describe 'Enums' do
    it { should define_enum_for(:status).with_values([:pending, :canceled]) }
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:room) }
  end

  describe 'Validations' do
    context 'check_in' do
      it { is_expected.to validate_presence_of(:check_in) }
    end

    context 'check_out' do
      it { is_expected.to validate_presence_of(:check_out) }
    end

    context 'check_in_and_check_out_are_not_in_the_past' do
      before :all do
        @reservation = FactoryBot.build(:room_reservation, check_in: (Date.today - 3.days),
                                                           check_out: (Date.today - 1.days))
      end
      
      it 'adds error messages to check_in and check_out when one of them or both of them are in the past' do
        expect(@reservation).to be_invalid
        expect(@reservation.errors[:check_in]).to include('can not be in the past')
        expect(@reservation.errors[:check_out]).to include('can not be in the past')
      end
    end

    context 'check_out_is_after_check_in' do
      before :all do
        @reservation = FactoryBot.build(:room_reservation, check_in: (Date.today + 3.days),
                                                           check_out: (Date.today + 1.days))
      end
      
      it 'adds error message indicating that check_out is before check_in' do
        expect(@reservation).to be_invalid
        expect(@reservation.errors[:check_out]).to include('must be after the check-in')
      end
    end

    context 'room_is_available' do
      before :all do
        user1 = FactoryBot.create(:user)
        user2 = FactoryBot.create(:user)
        room = FactoryBot.create(:room)
        check_in_date = Date.today + 1.days
        check_out_date = Date.today + 3.days
        first_reservation = described_class.create(check_in: check_in_date,
                                                   check_out: check_out_date,
                                                   user: user1,
                                                   room: room)
        @second_reservation = described_class.create(room: room,
                                                     user: user2,
                                                     check_in: check_in_date,
                                                     check_out:check_out_date)
      end
      
      it 'adds error message indicating that room is not available in the requested period' do
        expect(@second_reservation).to be_invalid
        expect(@second_reservation.errors[:room]).to include('is not available in the requested period')
      end
    end
  end
end
