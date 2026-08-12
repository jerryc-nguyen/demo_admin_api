require 'rails_helper'

RSpec.describe "Api::V1::Reports::DailyFinanceReports", type: :request do
  let(:user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { "Authorization" => "Bearer #{token}" } }

  describe "GET /api/v1/reports/daily_finance_reports" do
    context "when authenticated" do
      it "returns a list of daily finance reports" do
        create_list(:daily_finance_report, 3)

        get "/api/v1/reports/daily_finance_reports", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.size).to eq(3)
      end
    end

    context "when unauthenticated" do
      it "returns 401 Unauthorized" do
        get "/api/v1/reports/daily_finance_reports"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /api/v1/reports/daily_finance_reports" do
    let(:valid_params) do
      {
        daily_finance_report: {
          date: Date.today.to_s,
          value_type: "pos_revenue",
          value: 123.45
        }
      }
    end

    context "when authenticated" do
      context "with valid parameters" do
        it "creates a new DailyFinanceReport" do
          expect {
            post "/api/v1/reports/daily_finance_reports", params: valid_params, headers: headers
          }.to change(DailyFinanceReport, :count).by(1)

          expect(response).to have_http_status(:created)
          json = JSON.parse(response.body)
          expect(json["value_type"]).to eq("pos_revenue")
          expect(BigDecimal(json["value"])).to eq(BigDecimal("123.45"))
        end
      end

      context "with invalid parameters" do
        it "returns unprocessable_entity status" do
          invalid_params = { daily_finance_report: { date: "", value: -10.0 } }
          post "/api/v1/reports/daily_finance_reports", params: invalid_params, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json).to have_key("errors")
        end
      end
    end

    context "when unauthenticated" do
      it "returns 401 Unauthorized" do
        post "/api/v1/reports/daily_finance_reports", params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PUT/PATCH /api/v1/reports/daily_finance_reports/:id" do
    let!(:report) { create(:daily_finance_report, value: 100.0) }
    let(:update_params) { { daily_finance_report: { value: 200.0 } } }

    context "when authenticated" do
      it "updates the report" do
        patch "/api/v1/reports/daily_finance_reports/#{report.id}", params: update_params, headers: headers

        expect(response).to have_http_status(:ok)
        report.reload
        expect(report.value.to_f).to eq(200.0)
      end
    end

    context "when unauthenticated" do
      it "returns 401 Unauthorized" do
        patch "/api/v1/reports/daily_finance_reports/#{report.id}", params: update_params
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/v1/reports/daily_finance_reports/:id" do
    let!(:report) { create(:daily_finance_report) }

    context "when authenticated" do
      it "deletes the report" do
        expect {
          delete "/api/v1/reports/daily_finance_reports/#{report.id}", headers: headers
        }.to change(DailyFinanceReport, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context "when unauthenticated" do
      it "returns 401 Unauthorized" do
        delete "/api/v1/reports/daily_finance_reports/#{report.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
