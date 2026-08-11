module Reports
  module ViewFinanceReport
    class SummaryMetricBuilder
      def initialize(current_chart_data:, previous_chart_data:, current_strategy:, previous_strategy:)
        @current_chart_data = current_chart_data
        @previous_chart_data = previous_chart_data
        @current_strategy = current_strategy
        @previous_strategy = previous_strategy
      end

      def call
        [
          total_revenue_metric,
          average_per_day_metric,
          total_cover_metric
        ]
      end

      private

      attr_reader :current_chart_data, :previous_chart_data, :current_strategy, :previous_strategy

      def total_revenue_metric
        current_val = sum_revenue(current_chart_data)
        previous_val = previous_chart_data ? sum_revenue(previous_chart_data) : nil

        {
          title: "Total Revenue",
          value: current_val.to_f.round(2),
          previousValue: previous_val&.to_f&.round(2)
        }
      end

      def average_per_day_metric
        current_revenue = sum_revenue(current_chart_data)
        current_days = days_in_range(current_strategy.display_range)
        current_avg = current_days > 0 ? (current_revenue / current_days) : 0

        previous_avg = nil
        if previous_chart_data && previous_strategy
          previous_revenue = sum_revenue(previous_chart_data)
          previous_days = days_in_range(previous_strategy.display_range)
          previous_avg = previous_days > 0 ? (previous_revenue / previous_days) : 0
        end

        {
          title: "Average per Day",
          value: current_avg.to_f.round(2),
          previousValue: previous_avg&.to_f&.round(2)
        }
      end

      def total_cover_metric
        {
          title: "Total Cover",
          value: 1250,
          previousValue: previous_chart_data ? 1100 : nil
        }
      end

      def sum_revenue(chart_data)
        chart_data.sum { |row| row[:pos_revenue] + row[:eatclub_revenue] }
      end

      def days_in_range(range)
        (range.end - range.begin).to_i + 1
      end
    end
  end
end
