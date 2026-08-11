module Api
  module V1
    module Reports
      class FinanceReportsController < ApplicationController
        include AuthenticateRequest

        def index
          date_range_mode = params[:date_range_mode].presence || "this_week"
          display_mode, target_date = resolve_date_range(date_range_mode)

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

        def resolve_date_range(mode)
          case mode
          when "this_month"
            [:month, Date.current]
          when "this_year"
            [:year, Date.current]
          when "this_week"
            [:week, Date.current]
          else
            [:week, Date.current] # Fallback
          end
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
