require 'rails_helper'

RSpec.describe "Api::V1::Auths", type: :request do
  describe "POST /api/v1/auth/register" do
    let(:valid_attributes) do
      {
        email: "newuser@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    end

    context "with valid parameters" do
      it "registers a new user and returns a token" do
        post "/api/v1/auth/register", params: valid_attributes

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key("access_token")
        expect(json_response["email"]).to eq("newuser@example.com")
      end
    end

    context "with invalid parameters" do
      it "returns validation errors" do
        post "/api/v1/auth/register", params: { email: "", password: "" }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key("errors")
      end
    end
  end

  describe "POST /api/v1/auth/login" do
    let!(:user) { create(:user, email: "loginuser@example.com", password: "password123") }

    context "with valid credentials" do
      it "authenticates user and returns a token" do
        post "/api/v1/auth/login", params: { email: "loginuser@example.com", password: "password123" }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key("access_token")
        expect(json_response["email"]).to eq("loginuser@example.com")
      end
    end

    context "with invalid credentials" do
      it "returns unauthorized status" do
        post "/api/v1/auth/login", params: { email: "loginuser@example.com", password: "wrongpassword" }

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Invalid email or password")
      end
    end
  end
end
