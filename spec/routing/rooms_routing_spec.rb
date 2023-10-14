require "rails_helper"

RSpec.describe RoomsController, type: :routing do
  describe "routing" do
    it { should route(:get, '/rooms').to(action: :index) }
    it { should route(:post, '/rooms').to(action: :create) }
    it { should route(:put, '/rooms/1').to(action: :update, id: 1) }
  end
end
