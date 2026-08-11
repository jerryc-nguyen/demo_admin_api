module Reports
  module ViewFinanceReport
    class EchartOptionMerger
      def self.call(current_options, previous_options)
        new(current_options, previous_options).call
      end

      def initialize(current_options, previous_options)
        @current_options = current_options
        @previous_options = previous_options
      end

      def call
        return current_options if previous_options.blank? || previous_options[:series].blank?

        merged_series = current_options[:series] + previous_options[:series].map do |series|
          merged_item = series.merge(name: "#{series[:name]} (Previous)")
          merged_item[:stack] = "#{series[:stack]} (Previous)" if series[:stack]
          merged_item
        end

        current_options.merge(series: merged_series)
      end

      private

      attr_reader :current_options, :previous_options
    end
  end
end
