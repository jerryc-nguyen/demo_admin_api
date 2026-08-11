module Reports
  module ViewFinanceReport

    class EchartBuilder
      SERIES = [
        { name: "POS Revenue", value_key: :pos_revenue, stack: "Revenue", color: "#3b82f6", prev_color: "rgba(59, 130, 246, 0.5)" },
        { name: "EatClub Revenue", value_key: :eatclub_revenue, stack: "Revenue", color: "#10b981", prev_color: "rgba(16, 185, 129, 0.5)" },
        { name: "Labour Cost", value_key: :labour_cost, stack: nil, color: "#f59e0b", prev_color: "rgba(245, 158, 11, 0.5)" }
      ].freeze

      def initialize(chart_data, strategy, value_types: nil)
        @chart_data = chart_data
        @strategy = strategy
        @value_types = value_types
      end

      def call
        {
          legend: { show: true },
          tooltip: { trigger: "axis" },
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
            data: data_for(series[:value_key]),
            itemStyle: { color: series[:color] }
          }.merge(series[:stack] ? { stack: series[:stack] } : {})
        end
      end

      def data_for(value_key)
        chart_data.map { |row| row[value_key].to_f }
      end

      def selected_series
        return SERIES if value_types.nil?

        SERIES.select { |series| value_types.include?(series[:value_key].to_s) }
      end
    end
  end

end
