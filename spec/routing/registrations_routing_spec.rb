require "rails_helper"

RSpec.describe RegistrationsController, type: :routing do
  describe "routing" do
    it { should route(:post, '/auth').to(action: :create) }
  end
end
