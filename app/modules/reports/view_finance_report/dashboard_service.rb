module Reports
  module ViewFinanceReport
    class DashboardService
      def self.call(display_mode:, target_date:, value_types: nil, compare_with_previous: false)
        new(display_mode: display_mode, target_date: target_date, value_types: value_types, compare_with_previous: compare_with_previous).call
      end

      def initialize(display_mode:, target_date:, value_types: nil, compare_with_previous: false)
        @display_mode = (display_mode.presence || :week).to_sym
        @target_date = target_date
        @value_types = value_types
        @compare_with_previous = compare_with_previous
      end

      def call
        current_strategy = ::Reports::ChartOptions::StrategyFactory.for(display_mode, target_date)
        current_chart_data = ::Reports::ViewFinanceReport::FinanceReportChartQuery.call(current_strategy)

        if compare_with_previous
          previous_date = calculate_previous_date
          previous_strategy = ::Reports::ChartOptions::StrategyFactory.for(display_mode, previous_date)
          previous_chart_data = ::Reports::ViewFinanceReport::FinanceReportChartQuery.call(previous_strategy)
        else
          previous_strategy = nil
          previous_chart_data = nil
        end

        chart_options = ::Reports::ViewFinanceReport::EchartBuilder.new(
          current_chart_data,
          current_strategy,
          value_types: value_types
        ).call

        metrics = ::Reports::ViewFinanceReport::SummaryMetricBuilder.new(
          current_chart_data: current_chart_data,
          previous_chart_data: previous_chart_data,
          current_strategy: current_strategy,
          previous_strategy: previous_strategy
        ).call

        {
          chart_options: chart_options,
          metrics: metrics
        }
      end

      private

      attr_reader :display_mode, :target_date, :value_types, :compare_with_previous

      def calculate_previous_date
        case display_mode
        when :week
          target_date - 1.week
        when :month
          target_date - 1.month
        when :year
          target_date - 1.year
        else
          target_date - 1.week
        end
      end
    end
  end
end
