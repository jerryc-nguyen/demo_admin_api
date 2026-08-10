module Api
  module V1
    module Reports
      class FinanceReportsController < ApplicationController
        def index
          display_mode = params[:display_mode].presence || :week
          target_date = parse_date_param(params[:current_date])

          strategy = ::Reports::ChartOptions::StrategyFactory.for(display_mode, target_date)
          chart_data = ::Reports::ViewFinanceReport::FinanceReportChartQuery.call(strategy)
          value_types = parse_value_types_param(params[:value_types])
          render json: ::Reports::ViewFinanceReport::EchartBuilder.new(chart_data, strategy, value_types: value_types).call
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

        def parse_value_types_param(raw)
          return nil if raw.nil?
          return [] if raw.strip.empty?
          raw.split(",")
             .map(&:strip)
             .reject(&:empty?)
             .select { |vt| DailyFinanceReport::VALID_VALUE_TYPES.include?(vt) }
        end
      end
    end
  end
end
