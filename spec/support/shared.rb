module Shared
  shared_context 'authentication_params' do
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
  end

  shared_context 'Guest user signed_in successfully' do
    @user = FactoryBot.create(:user)
    authorization = @user.create_new_auth_token
    authorization.each do |key, value|
      let(key) { value }
    end
  end

  shared_context 'Admin user signed_in successfully' do
    @user = FactoryBot.create(:user, role: User.roles[:admin])
    authorization = @user.create_new_auth_token
    authorization.each do |key, value|
      let(key) { value }
    end
  end

  shared_context 'no user is signed_in' do
    invalid_user_token = { 'access-token' => '',
                           'token-type' => '',
                           'client' => '',
                           'expiry' => '',
                           'uid' => '',
                           'Authorization' => '' }
    invalid_user_token.each do |key, value|
      let(key) { value }
    end
  end

  shared_examples 'unauthenticated_user' do
    run_test! do |response|
      data = JSON.parse(response.body)
      expect(data['errors']).to eq(['You need to sign in or sign up before continuing.'])
    end
  end

  shared_examples 'unauthorized_user' do
    run_test! do |response|
      data = JSON.parse(response.body)
      expect(data).to eq(['You are not authorized to perform this action'])
    end
  end
end