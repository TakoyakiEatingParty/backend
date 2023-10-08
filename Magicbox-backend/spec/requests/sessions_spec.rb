# spec/controllers/session_controller_spec.rb
require 'rails_helper'

RSpec.describe SessionController, type: :controller do
  describe "GET #github_auth" do
    it "redirects to GitHub for authentication" do
      get :github_auth
      expect(response).to redirect_to(%r{github\.com/login/oauth/authorize})
    end
  end

  describe "POST #github_callback" do
    let(:fake_access_token) { 'fake_access_token' }
    let(:fake_user_info) do
      {
        provider: 'github',
        uid: Faker::Internet.uuid,
        name: Faker::Name.name,
        image_url: Faker::Avatar.image,
        email: Faker::Internet.email
      }
    end

    before do
      allow(controller).to receive(:github_access_token).and_return(fake_access_token)
      allow(controller).to receive(:fetch_github_user_info).and_return(fake_user_info)
    end

    context "when authentication is successful" do
      it "creates a new user or finds an existing one" do
        expect do
          post :github_callback, params: { code: 'fake_code' }
        end.to change(User, :count).by(1)
      end

      it "redirect to root" do
        post :github_callback, params: { code: 'fake_code' }
        expect(response.location).to match(/#{ENV.fetch('FRONTEND_URL', nil)}/)
      end
    end

    context "when authentication fails" do
      before do
        allow(controller).to receive(:fetch_github_user_info).and_return(nil)
      end

      it "raises an error" do
        expect do
          post :github_callback, params: { code: 'fake_code' }
        end.to raise_error(RuntimeError, 'Unable to authenticate with GitHub')
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:user) { create(:user) }
    let(:jwt_payload) { { user_id: user.id, jti: SecureRandom.uuid, exp: 1.week.from_now.to_i } }
    let!(:token) { JWT.encode(jwt_payload, Rails.application.credentials.secret_key_base, 'HS256') }

    before do
      create(:jwt_token, jti: jwt_payload[:jti], exp: Time.at(jwt_payload[:exp]))
      request.headers['Authorization'] = "Bearer #{token}" # ここでエンコードされたJWTをセットします。
    end

    context "when the token exists" do
      it "destroys the token and logs out the user" do
        expect do
          delete :destroy
        end.to change(JwtToken, :count).by(-1)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Logged out successfully')
      end
    end

    context "when the token does not exist" do
      before do
        request.headers['Authorization'] = "Bearer non_existing_token"
      end

      it "returns a not found response" do
        delete :destroy
        expect(response.body).to include('Token not found')
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
