require 'swagger_helper'

RSpec.describe 'rooms', type: :request do

  let (:valid_room_params) { { capacity: 2, price_per_night: 14.5 } }
  let (:invalid_room_params) { { capacity: 'wrong_value' } }

  path '/rooms' do

    get('list rooms') do
      before :all do
        Room.destroy_all
        FactoryBot.create_list(:room, 5)
      end

      tags "Room index"
      consumes 'application/json'
      parameter name: 'access-token', in: :header, type: :string, required: true,
                description: 'can be optained from the headers response of the sign-in action'
      parameter name: 'token-type', in: :header, type: :string, required: true,
                description: 'can be optained from the headers response of the sign-in action'
      parameter name: 'client', in: :header, type: :string, required: true,
                description: 'can be optained from the headers response of the sign-in action'
      parameter name: 'expiry', in: :header, type: :string, required: true,
                description: 'can be optained from the headers response of the sign-in action'
      parameter name: 'uid', in: :header, type: :string, required: true,
                description: 'can be optained from the headers response of the sign-in action'
      parameter name: 'Authorization', in: :header, type: :string, required: true,
                description: 'can be optained from the headers response of the sign-in action'

      response(200, 'Successful when user is signed-in') do
        user = FactoryBot.create(:user)
        authorization = user.create_new_auth_token
        authorization.each do |key, value|
          let(key) { value }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.count).to eq(5)
        end
      end

      response(401, 'Un-authorized when no user is signed-in') do
        invalid_user_token = { 'access-token' => '',
                               'token-type' => '',
                               'client' => '',
                               'expiry' => '',
                               'uid' => '',
                               'Authorization' => '' }
        invalid_user_token.each do |key, value|
          let(key) { value }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to eq(["You need to sign in or sign up before continuing."])
        end
      end
    end

    post('create room') do
      tags "Room Creation"
      consumes 'application/json'
      parameter name: 'access-token', in: :header, type: :string, required: true,
                description: 'can be optained from the headers response of the sign-in action'
      parameter name: 'token-type', in: :header, type: :string, required: true,
                description: 'can be optained from the headers response of the sign-in action'
      parameter name: 'client', in: :header, type: :string, required: true,
                description: 'can be optained from the headers response of the sign-in action'
      parameter name: 'expiry', in: :header, type: :string, required: true,
                description: 'can be optained from the headers response of the sign-in action'
      parameter name: 'uid', in: :header, type: :string, required: true,
                description: 'can be optained from the headers response of the sign-in action'
      parameter name: 'Authorization', in: :header, type: :string, required: true,
                description: 'can be optained from the headers response of the sign-in action'
      parameter name: :room, in: :body, schema: {
        type: :object,
        properties: {
          capacity: { type: :integer, example: 2 },
          price_per_night: { type: :decimal, example: 15.57 },
          description: { type: :string, example: 'Our most luxurious room' }  
        },
        required: ['capacity', 'price_per_night']
      }
          

      response(201, 'Successful creation') do
        user = FactoryBot.create(:user)
        authorization = user.create_new_auth_token
        authorization.each do |key, value|
          let(key) { value }
        end
        let(:room) { valid_room_params }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['capacity']).to eq(2)
          expect(data['price_per_night'].to_d).to eq(14.5)
        end
      end

      response(422, 'Creation fails on invalid parameters') do
        user = FactoryBot.create(:user)
        authorization = user.create_new_auth_token
        authorization.each do |key, value|
          let(key) { value }
        end
        let(:room) { invalid_room_params }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to include('Capacity is not a number')
          expect(data).to include("Price per night can't be blank")
          expect(data).to include('Price per night is not a number')
        end
      end


      response(401, 'Un-authorized when no user is signed-in') do
        invalid_user_token = { 'access-token' => '',
                               'token-type' => '',
                               'client' => '',
                               'expiry' => '',
                               'uid' => '',
                               'Authorization' => '' }
        invalid_user_token.each do |key, value|
          let(key) { value }
        end
        let(:room) { valid_room_params }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to eq(["You need to sign in or sign up before continuing."])
        end
      end
    end
  end

  path '/rooms/{id}' do
    parameter name: 'access-token', in: :header, type: :string, required: true,
              description: 'can be optained from the headers response of the sign-in action'
    parameter name: 'token-type', in: :header, type: :string, required: true,
              description: 'can be optained from the headers response of the sign-in action'
    parameter name: 'client', in: :header, type: :string, required: true,
              description: 'can be optained from the headers response of the sign-in action'
    parameter name: 'expiry', in: :header, type: :string, required: true,
              description: 'can be optained from the headers response of the sign-in action'
    parameter name: 'uid', in: :header, type: :string, required: true,
              description: 'can be optained from the headers response of the sign-in action'
    parameter name: 'Authorization', in: :header, type: :string, required: true,
              description: 'can be optained from the headers response of the sign-in action'
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

      response(200, 'successful') do
        let(:id) { @room.id }
        user = FactoryBot.create(:user)
        authorization = user.create_new_auth_token
        authorization.each do |key, value|
          let(key) { value }
        end
        let(:room) { { description: 'my new description' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(@room.id)
          expect(data['description']).to eq('my new description')
        end
      end

      response(422, 'Unsucessful due to invalid parameters') do
        let(:id) { @room.id }
        user = FactoryBot.create(:user)
        authorization = user.create_new_auth_token
        authorization.each do |key, value|
          let(key) { value }
        end
        let(:room) { { capacity: nil } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to include("Capacity can't be blank")
          expect(data).to include('Capacity is not a number')
        end
      end

      response(401, 'Un-authorized when no user is signed-in') do
        let(:id) { @room.id }
        invalid_user_token = { 'access-token' => '',
                               'token-type' => '',
                               'client' => '',
                               'expiry' => '',
                               'uid' => '',
                               'Authorization' => '' }
        invalid_user_token.each do |key, value|
          let(key) { value }
        end
        let(:room) { valid_room_params }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to eq(["You need to sign in or sign up before continuing."])
        end
      end

      response(404, 'Not-found when sending room id that does not exist') do
        let(:id) { 'hey' }
        user = FactoryBot.create(:user)
        authorization = user.create_new_auth_token
        authorization.each do |key, value|
          let(key) { value }
        end
        let(:room) { valid_room_params }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to include('No record was found with given ID')
        end
      end
    end

    put('update room') do
      tags "Room put Update (just testing successful scenario as other scenarios are tested in patch)"
      consumes 'application/json'

      response(200, 'successful') do
        let(:id) { @room.id }
        user = FactoryBot.create(:user)
        authorization = user.create_new_auth_token
        authorization.each do |key, value|
          let(key) { value }
        end
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
