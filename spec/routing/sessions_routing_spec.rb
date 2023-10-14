require "rails_helper"

RSpec.describe SessionsController, type: :routing do
  describe "routing" do
    it { should route(:post, '/auth/sign_in').to(action: :create) }
  end
end
