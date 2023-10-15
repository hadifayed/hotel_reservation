require 'swagger_helper'

RSpec.describe 'room_reservations', type: :request do
  let (:valid_room_reservation_params) do
    { check_in: "#{Date.current + 1.days }", check_out: "#{Date.current + 3.days }", room_id: 3333 }
  end

  path '/room_reservations/within_range' do
    include_context 'authentication_params'

    parameter name: :room_reservation, in: :query, schema: {
      type: :object,
      properties: {
        'room_reservation[check_in]' => { type: :string, example: '01-01-2023' },
        'room_reservation[check_out]' => { type: :string, example: '01-01-2023' }
      }
    }

    get('within_range room_reservation') do
      tags 'Reservations Within range'
      consumes 'application/json'
  
      response(200, 'Successful') do
        include_context 'user signed_in successfully'

        room_reservations = FactoryBot.create_list(:room_reservation, 3, user: @user,
                                                                         check_in: (Date.current + 1.days).to_s,
                                                                         check_out: (Date.current + 3.days).to_s)
        let(:room_reservation) { { room_reservation: { check_in: (Date.current + 1.days).to_s,
                                                       check_out: (Date.current + 3.days).to_s } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.count).to eq(3)
        end
      end

      response(401, 'Un-authenticated when no user is signed-in') do
        include_context 'no user is signed_in'

        let(:room_reservation) { { room_reservation: { check_in: '01-01-2024', check_out: '10-01-2024' } } }

        it_behaves_like 'unauthenticated_user'
      end

      response(400, 'Bad request when given invalid format for check-in, check-out or both') do
        include_context 'user signed_in successfully'

        context 'invalid check-in format' do
          let(:room_reservation) { { room_reservation: { check_in: 'wrong', check_out: '10-01-2024' } } }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).to include('Invalid range when parsing check_in and check_out')
          end
        end

        context 'invalid check-out format' do
          let(:room_reservation) { { room_reservation: { check_out: 'wrong', check_in: '10-01-2024' } } }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).to include('Invalid range when parsing check_in and check_out')
          end
        end

        context 'invalid format for both fields' do
          let(:room_reservation) { { room_reservation: { check_out: nil, check_in: nil } } }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).to include('Invalid range when parsing check_in and check_out')
          end
        end
      end
    end
  end

  path '/room_reservations/{id}/cancel' do
    include_context 'authentication_params'

    parameter name: 'id', in: :path, type: :string, description: 'RoomReservation ID'

    patch('cancel room_reservation') do
      tags "Cancel specific Room Reservation (must be authenticated user's reservation)"
      consumes 'application/json'
  
      response(200, 'Successful cancelation') do
        include_context 'user signed_in successfully'

        RoomReservation.find_by(id: 1111)&.destroy
        FactoryBot.create(:room_reservation, id: 1111, user: @user, status: RoomReservation.statuses[:pending])

        let(:id) { 1111 }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(1111)
          expect(data['status']).to eq('canceled')
        end
      end

      response(401, 'Un-authenticated when no user is signed-in') do
        include_context 'no user is signed_in'

        let(:id) { 1 }

        it_behaves_like 'unauthenticated_user'
      end

      response(400, 'Bad request when user sends reservation id that does not belong to them') do
        include_context 'user signed_in successfully'

        RoomReservation.find_by(id: 2222)&.destroy
        FactoryBot.create(:room_reservation, id: 2222, status: RoomReservation.statuses[:pending])

        let(:id) { 2222 }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to include('No reservation found with this id')
        end
      end
    end
  end

  path '/room_reservations' do
    include_context 'authentication_params'

    post('create room_reservation') do
      tags "Create Room Reservation"
      consumes 'application/json'

      parameter name: :room_reservation, in: :body, schema: {
        type: :object,
        properties: {
          check_in: { type: :string, example: '01-01-2023' },
          check_out: { type: :string, example: '10-01-2023' },
          room_id: { type: :integer, example: 1, description: 'reference to an already existing room' }  
        },
        required: ['check_in', 'check_out', 'room_id']
      }
  

      before :all do
        Room.find_by(id: 3333)&.destroy
        FactoryBot.create(:room, id: 3333)
      end

      response(201, 'Successful creation') do
        include_context 'user signed_in successfully'

        let(:room_reservation) { valid_room_reservation_params }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['room_id']).to eq(3333)
          expect(data['status']).to eq('pending')
        end
      end

      response(422, 'Creation failed due to invalid params') do
        context "when check_in field is missing" do
          include_context 'user signed_in successfully'

          let(:room_reservation) { { check_out: "#{Date.current + 3.days}", room_id: 3333 } }
          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).to include("Check-in can't be blank")
          end            
        end

        context "when check_out field is missing" do
          include_context 'user signed_in successfully'

          let(:room_reservation) { { check_in: "#{Date.current + 3.days}", room_id: 3333 } }
          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).to include("Check-out can't be blank")
          end            
        end

        context "when room_id field is missing" do
          include_context 'user signed_in successfully'

          let(:room_reservation) { { check_in: "#{Date.current + 1.days}", check_out: "#{Date.current + 3.days}" } }
          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).to include("Room must exist")
          end            
        end

        context "when given wrong room_id field" do
          include_context 'user signed_in successfully'

          let(:room_reservation) { { check_in: "#{Date.current + 1.days}", check_out: "#{Date.current + 3.days}", room_id: 'hey' } }
          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).to include("Room must exist")
          end            
        end

        context "when check_in and check_out are in the past" do
          include_context 'user signed_in successfully'

          let(:room_reservation) { { check_in: "#{Date.current - 3.days}", check_out: "#{Date.current - 1.days}", room_id: 3333 } }
          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).to include("Check-out can not be in the past")
            expect(data).to include("Check-in can not be in the past")
          end            
        end

        context "when check_in is after check_out" do
          include_context 'user signed_in successfully'

          let(:room_reservation) { { check_in: "#{Date.current + 3.days}", check_out: "#{Date.current + 1.days}", room_id: 3333 } }
          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).to include("Check-out must be after the check-in")
          end            
        end

        context "when room is already booked in the requested period" do
          include_context 'user signed_in successfully'
          room_reservation = FactoryBot.create(:room_reservation)
          params = { check_in: room_reservation.check_in.to_s,
                     check_out: room_reservation.check_out.to_s,
                     room_id: room_reservation.room_id }

          let(:room_reservation) { params }
          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).to include("Room is not available in the requested period")
          end
        end
      end

      response(401, 'Un-authenticated when no user is signed-in') do
        include_context 'no user is signed_in'

        let(:room_reservation) {  { check_in: '01-01-2023', check_out: '01-01-2022', room_id: 1 } }

        it_behaves_like 'unauthenticated_user'
      end
    end
  end
end
