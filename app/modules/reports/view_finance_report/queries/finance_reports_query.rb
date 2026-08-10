module Reports
  module ViewFinanceReport
    module Queries
      class FinanceReportsQuery
        def self.call(start_date, end_date)
          DailyFinanceReport.where(date: start_date..end_date)
        end
      end
    end
  end
end
