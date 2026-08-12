require 'rails_helper'

RSpec.describe "Api::V1::Reports::FinanceReports", type: :request do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { "Authorization" => "Bearer #{token}" } }

  describe "GET /api/v1/reports/finance_reports" do
    context "when authenticated" do
      it "returns 200 OK and dashboard data structures" do
        get "/api/v1/reports/finance_reports", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to have_key("chart_options")
        expect(json).to have_key("previous_chart_options")
        expect(json).to have_key("metrics")
      end

      it "accepts parameters and forwards to dashboard service" do
        get "/api/v1/reports/finance_reports", 
            params: { date_range_mode: "this_month", value_types: "pos_revenue", compare_with_previous: "true" },
            headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to have_key("chart_options")
      end
    end

    context "when unauthenticated" do
      it "returns 401 Unauthorized" do
        get "/api/v1/reports/finance_reports"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
