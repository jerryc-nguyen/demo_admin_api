module Reports
  module ViewFinanceReport
    class FinanceReportChartQuery
      attr_reader :strategy

      STEP_INTERVALS = { day: "1 day", month: "1 month" }.freeze
      JOIN_CONDITIONS = {
        day: "reports.date = days.date",
        month: "DATE_TRUNC('month', reports.date) = days.date"
      }.freeze

      def self.call(strategy)
        new(strategy).call
      end

      def initialize(strategy)
        @strategy = strategy
      end

      def call
        rows = ActiveRecord::Base.connection.exec_query(sql, "FinanceReportChartQuery", binds).rows
        rows.map do |row|
          {
            period: row[0].to_date,
            pos_revenue: BigDecimal(row[1].to_s),
            eatclub_revenue: BigDecimal(row[2].to_s),
            labour_cost: BigDecimal(row[3].to_s)
          }
        end
      end

      private

      def sql
        <<~SQL
          WITH days AS (
            SELECT generate_series($1::date, $2::date, interval '#{step}')::date AS date
          )

          SELECT
            days.date AS period,
            COALESCE(SUM(value) FILTER (WHERE value_type = 'pos_revenue'), 0) AS pos_revenue,
            COALESCE(SUM(value) FILTER (WHERE value_type = 'eatclub_revenue'), 0) AS eatclub_revenue,
            COALESCE(SUM(value) FILTER (WHERE value_type = 'labour_cost'), 0) AS labour_cost
          FROM days
          LEFT JOIN daily_finance_reports reports
            ON #{join_condition}
          GROUP BY days.date
          ORDER BY days.date
        SQL
      end

      def step
        STEP_INTERVALS.fetch(strategy.aggregation)
      end

      def join_condition
        JOIN_CONDITIONS.fetch(strategy.aggregation)
      end

      def binds
        [
          build_attribute("start_date", strategy.display_range.begin),
          build_attribute("end_date", strategy.display_range.end)
        ]
      end

      def build_attribute(name, value)
        ActiveRecord::Relation::QueryAttribute.new(name, value, ActiveRecord::Type::Date.new)
      end
    end
  end

end
