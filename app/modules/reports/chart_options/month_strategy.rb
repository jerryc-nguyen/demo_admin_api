module Reports
  module ChartOptions
    class MonthStrategy < DisplayStrategy
      def display_range
        date.beginning_of_month..date.end_of_month
      end

      def aggregation
        :day
      end

      def periods
        display_range.to_a
      end

      def label_format(period_date)
        period_date.strftime("%b %d")
      end
    end
  end
end
