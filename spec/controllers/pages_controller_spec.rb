describe PagesController do
  context "#index" do
    it "returns success" do
      get :index
      expect(response).to be_success
    end
  end
end