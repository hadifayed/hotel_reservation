require 'swagger_helper'

RSpec.describe 'registrations', type: :request do

  path '/auth' do

    post('create user') do
      tags "Users Creation"
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: "hadi@test.com" },
          password: { type: :string, example: "hadi1234" },
          name: { type: :string, example: "Hadi" }
        },
        required: ['email', 'password', 'name']
      }

      response(200, 'Successful creation') do
        let(:user) { { email: 'test1@test.com', name: 'test', password: 'test1234' } }
        run_test!
      end

      response(422, 'Unsuccessful creation') do
        context 'Duplicate email' do
          params = { email: 'test@test.com', name: 'test', password: 'test1234' }
          User.create(params)
          let(:user) { params }
          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['errors']['email']).to eq(["has already been taken"])
          end
        end

        %i[email name password].each do |field|
          context "Missing #{field}" do
            params = { name: 'test', password: 'test1234', email: "hadi22@test.com" }
            params.delete(field)
            let(:user) { params }
            run_test! do |response|
              data = JSON.parse(response.body)
              expect(data['errors'][field.to_s]).to eq(["can't be blank"])
            end  
          end
        end
      end
    end
  end
end
