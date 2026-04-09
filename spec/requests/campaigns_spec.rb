require 'rails_helper'

RSpec.describe "Campaigns", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/campaigns/index"
      expect(response).to have_http_status(:success)
    end
  end

end
