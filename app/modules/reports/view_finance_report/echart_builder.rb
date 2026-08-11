module Reports
  module ViewFinanceReport

    class EchartBuilder
      SERIES = [
        { name: "POS Revenue", value_key: :pos_revenue, stack: "Revenue", color: "rgb(5, 0, 35)", prev_color: "rgba(5, 0, 35, 0.35)" },
        { name: "EatClub Revenue", value_key: :eatclub_revenue, stack: "Revenue", color: "rgb(60, 17, 252)", prev_color: "rgba(60, 17, 252, 0.35)" },
        { name: "Labour Cost", value_key: :labour_cost, stack: nil, color: "rgb(242, 91, 21)", prev_color: "rgba(242, 91, 21, 0.35)" }
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
