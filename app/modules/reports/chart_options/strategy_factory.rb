module Reports
  module ChartOptions
    class StrategyFactory
      STRATEGIES = {
        week: WeekStrategy,
        month: MonthStrategy,
        year: YearStrategy
      }.freeze

      def self.for(mode, date)
        strategy_class = STRATEGIES[mode.to_sym]
        raise ArgumentError, "Unknown display_mode: #{mode}" unless strategy_class

        strategy_class.new(date)
      end
    end
  end
end
