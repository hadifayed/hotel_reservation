require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Enums' do
    it { should define_enum_for(:role).with_values([:guest, :admin]) }
  end

  describe 'Associations' do
    it { is_expected.to have_many(:room_reservations) }
  end

  describe 'Validations' do
    context 'name' do
      it { is_expected.to validate_presence_of(:name) }
    end
  end
end
