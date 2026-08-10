module Reports
  module ChartOptions
    class YearStrategy < DisplayStrategy
      def display_range
        date.beginning_of_year..date.end_of_year
      end

      def aggregation
        :month
      end

      def periods
        12.times.map { |i| display_range.begin + i.months }
      end

      def label_format(period_date)
        period_date.strftime("%b")
      end
    end
  end
end
