require 'swagger_helper'

RSpec.describe 'rooms', type: :request do

  let (:valid_room_params) { { capacity: 2, price_per_night: 14.5 } }
  let (:invalid_room_params) { { capacity: 'wrong_value' } }

  path '/rooms' do
    include_context 'authentication_params'

    get('list rooms') do
      before :all do
        Room.destroy_all
        FactoryBot.create_list(:room, 5)
      end

      tags "Room index"
      consumes 'application/json'

      response(200, 'Successful when user is signed-in') do
        include_context 'Guest user signed_in successfully'

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.count).to eq(5)
        end
      end

      response(401, 'Un-authenticated when no user is signed-in') do
        include_context 'no user is signed_in'

        it_behaves_like 'unauthenticated_user'
      end
    end

    post('create room') do
      tags "Room Creation"
      consumes 'application/json'

      parameter name: :room, in: :body, schema: {
        type: :object,
        properties: {
          capacity: { type: :integer, example: 2 },
          price_per_night: { type: :decimal, example: 15.57 },
          description: { type: :string, example: 'Our most luxurious room' }  
        },
        required: ['capacity', 'price_per_night']
      }

      response(201, 'Successful creation only when admin user is signed in') do
        include_context 'Admin user signed_in successfully'

        let(:room) { valid_room_params }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['capacity']).to eq(2)
          expect(data['price_per_night'].to_d).to eq(14.5)
        end
      end

      response(422, 'Creation fails on invalid parameters sent by admin user') do
        include_context 'Admin user signed_in successfully'

        let(:room) { invalid_room_params }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to include('Capacity is not a number')
          expect(data).to include("Price per night can't be blank")
          expect(data).to include('Price per night is not a number')
        end
      end


      response(401, 'Un-authenticated when no user is signed-in') do
        include_context 'no user is signed_in'

        let(:room) { valid_room_params }

        it_behaves_like 'unauthenticated_user'
      end

      response(403, 'Un-authorized when guest user is signed-in') do
        include_context 'Guest user signed_in successfully'

        let(:room) { valid_room_params }

        it_behaves_like 'unauthorized_user'
      end
    end
  end

  path '/rooms/{id}' do
    include_context 'authentication_params'

    parameter name: 'id', in: :path, type: :string, description: 'Room ID'
    parameter name: :room, in: :body, schema: {
      type: :object,
      properties: {
        capacity: { type: :integer, example: 2 },
        price_per_night: { type: :decimal, example: 15.57 },
        description: { type: :string, example: 'Our most luxurious room' }  
      }
    }

    before :all do
      @room = FactoryBot.create(:room)
    end

    patch('update room') do
      tags "Room patch Update"
      consumes 'application/json'

      response(200, 'successful update only when admin user is signed-in') do
        include_context 'Admin user signed_in successfully'

        let(:id) { @room.id }
        let(:room) { { description: 'my new description' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(@room.id)
          expect(data['description']).to eq('my new description')
        end
      end

      response(422, 'Unsucessful due to invalid parameters sent by admin user') do
        include_context 'Admin user signed_in successfully'

        let(:id) { @room.id }
        let(:room) { { capacity: nil } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to include("Capacity can't be blank")
          expect(data).to include('Capacity is not a number')
        end
      end

      response(401, 'Un-authenticated when no user is signed-in') do
        include_context 'no user is signed_in'

        let(:id) { @room.id }
        let(:room) { valid_room_params }

        it_behaves_like 'unauthenticated_user'
      end

      response(404, 'Not-found when sending room id that does not exist') do
        include_context 'Guest user signed_in successfully'

        let(:id) { 'hey' }
        let(:room) { valid_room_params }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to eq(['No room record was found with given ID'])
        end
      end

      response(403, 'Un-authorized when guest user is signed-in') do
        include_context 'Guest user signed_in successfully'

        let(:id) { @room.id }
        let(:room) { valid_room_params }

        it_behaves_like 'unauthorized_user'
      end
    end

    put('update room') do
      tags "Room put Update (just testing successful scenario as other scenarios are tested in patch)"
      consumes 'application/json'

      response(200, 'successful') do
        include_context 'Admin user signed_in successfully'

        let(:id) { @room.id }
        let(:room) { { description: 'my all brand new description' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(@room.id)
          expect(data['description']).to eq('my all brand new description')
        end
      end
    end
  end
end
