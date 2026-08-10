module Api
  module V1
    module Reports
      class FinanceReportsController < ApplicationController
        def index
          target_date = parse_date_param(params[:current_date])
          start_date = target_date.beginning_of_week
          end_date = start_date.end_of_week

          reports = ::Reports::ViewFinanceReport::Queries::FinanceReportsQuery.call(start_date, end_date)
          render json: ::Reports::ViewFinanceReport::Services::EchartReportBuilder.new(start_date, reports).call
        end

        private

        def parse_date_param(date_param)
          return Date.current if date_param.blank?
          Date.parse(date_param)
        rescue ArgumentError
          Date.current
        end
      end
    end
  end
end
