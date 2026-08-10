module Reports
  module ViewFinanceReport

    class EchartBuilder
      SERIES = [
        { name: "POS Revenue", value_key: :pos_revenue, stack: "Revenue" },
        { name: "EatClub Revenue", value_key: :eatclub_revenue, stack: "Revenue" },
        { name: "Labour Cost", value_key: :labour_cost, stack: nil }
      ].freeze

      def initialize(chart_data, strategy, value_types: nil)
        @chart_data = chart_data
        @strategy = strategy
        @value_types = value_types
      end

      def call
        {
          xAxis: { type: "category", data: labels },
          yAxis: { type: "value" },
          series: series_data
        }
      end

      private

      attr_reader :chart_data, :strategy, :value_types

      def labels
        chart_data.map { |row| strategy.label_format(row[:period]) }
      end

      def series_data
        selected_series.map do |series|
          {
            name: series[:name],
            type: "bar",
            data: chart_data.map { |row| row[series[:value_key]].to_f }
          }.merge(series[:stack] ? { stack: series[:stack] } : {})
        end
      end

      def selected_series
        return SERIES if value_types.nil?

        SERIES.select { |series| value_types.include?(series[:value_key].to_s) }
      end
    end
  end

end
