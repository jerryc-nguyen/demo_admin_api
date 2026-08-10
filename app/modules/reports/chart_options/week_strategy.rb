module Reports
  module ChartOptions
    class WeekStrategy < DisplayStrategy
      def display_range
        date.beginning_of_week..date.end_of_week
      end

      def aggregation
        :day
      end

      def periods
        display_range.to_a
      end

      def label_format(period_date)
        period_date.strftime("%a %m-%d")
      end
    end
  end
end
