module Reports
  module ViewFinanceReport
    module Services
      class EchartReportBuilder
        DAYS_OF_WEEK = %w[Mon Tue Wed Thu Fri Sat Sun].freeze

        def initialize(start_date, reports)
          @start_date = start_date
          @reports = reports
        end

        def call
          dates = (0..6).map { |i| @start_date + i }
          
          indexed_reports = @reports.each_with_object({}) do |report, hash|
            hash[[report.date, report.value_type]] = report.value.to_f
          end

          pos_revenue_data = dates.map { |date| indexed_reports[[date, "pos_revenue"]] || 0.0 }
          eatclub_revenue_data = dates.map { |date| indexed_reports[[date, "eatclub_revenue"]] || 0.0 }
          labour_cost_data = dates.map { |date| indexed_reports[[date, "labour_cost"]] || 0.0 }

          {
            categories: DAYS_OF_WEEK,
            dates: dates.map(&:to_s),
            series: [
              {
                name: "POS Revenue",
                type: "bar",
                stack: "Revenue",
                emphasis: { focus: "series" },
                data: pos_revenue_data
              },
              {
                name: "EatClub Revenue",
                type: "bar",
                stack: "Revenue",
                emphasis: { focus: "series" },
                data: eatclub_revenue_data
              },
              {
                name: "Labour Cost",
                type: "bar",
                emphasis: { focus: "series" },
                data: labour_cost_data
              }
            ]
          }
        end
      end
    end
  end
end
