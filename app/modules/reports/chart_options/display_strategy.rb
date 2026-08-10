module Reports
  module ChartOptions
    class DisplayStrategy
      def initialize(date)
        @date = date
      end

      def display_range
        raise NotImplementedError
      end

      def aggregation
        raise NotImplementedError
      end

      def periods
        raise NotImplementedError
      end

      def label_format(date)
        raise NotImplementedError
      end

      private

      attr_reader :date
    end
  end
end
