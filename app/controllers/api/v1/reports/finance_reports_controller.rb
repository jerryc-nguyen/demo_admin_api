module Api
  module V1
    module Reports
      class FinanceReportsController < ApplicationController
        def index
          display_mode = params[:display_mode].presence || :week
          target_date = parse_date_param(params[:current_date])
          value_types = parse_value_types_param(params[:value_types])
          compare_with_previous = ActiveModel::Type::Boolean.new.cast(params[:compare_with_previous])

          render json: ::Reports::ViewFinanceReport::DashboardService.call(
            display_mode: display_mode,
            target_date: target_date,
            value_types: value_types,
            compare_with_previous: compare_with_previous
          )
        rescue ArgumentError => e
          render json: { error: e.message }, status: :bad_request
        end

        private

        def parse_date_param(date_param)
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
