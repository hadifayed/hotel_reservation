require 'swagger_helper'

RSpec.describe 'sessions', type: :request do

  path '/auth/sign_in' do

    post('create session') do
      tags "Users Authentication"
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: "hadi@test.com" },
          password: { type: :string, example: "hadi1234" },
        },
        required: ['email', 'password']
      }

      response(200, 'successful') do
        user = FactoryBot.create(:user, password: 'hadi1234')
        let(:user) { { email: user.email, password: 'hadi1234' } }
        run_test!
      end

      response(401, 'invalid login credentials') do
        context 'email missing' do
          let(:user) { { password: 'hadi1234' } }
          run_test!
        end

        context 'password missing' do
          user = FactoryBot.create(:user)
          let(:user) { { email: user.email } }
          run_test!
        end

        context 'wrong credentials' do
          let(:user) { { email: 'none@existing.com', password: 'not_working' } }
          run_test!
        end
      end
    end
  end
end
