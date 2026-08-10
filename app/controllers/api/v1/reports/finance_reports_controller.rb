module Api
  module V1
    module Reports
      class FinanceReportsController < ApplicationController
        def index
          display_mode = params[:display_mode].presence || :week
          target_date = parse_date_param(params[:current_date])

          strategy = ::Reports::ChartOptions::StrategyFactory.for(display_mode, target_date)
          chart_data = ::Reports::ViewFinanceReport::FinanceReportChartQuery.call(strategy)
          render json: ::Reports::ViewFinanceReport::EchartBuilder.new(chart_data, strategy).call
        rescue ArgumentError => e
          render json: { error: e.message }, status: :bad_request
        end

        private

        def parse_date_param(date_param)
          return 1.week.ago
          return Date.current if date_param.blank?
          Date.parse(date_param)
        rescue ArgumentError
          Date.current
        end
      end
    end
  end
end
