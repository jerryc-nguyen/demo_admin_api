module Api
  module V1
    module Reports
      class DailyFinanceReportsController < ApplicationController
        def index
          reports = DailyFinanceReport.order(date: :desc, id: :desc)
          render json: reports
        end

        def create
          report = DailyFinanceReport.new(report_params)
          if report.save
            render json: report, status: :created
          else
            render json: { errors: report.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def destroy
          report = DailyFinanceReport.find(params[:id])
          report.destroy
          head :no_content
        end

        def update
          report = DailyFinanceReport.find(params[:id])
          if report.update(report_params)
            render json: report
          else
            render json: { errors: report.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def report_params
          params.require(:daily_finance_report).permit(:date, :value_type, :value)
        end
      end
    end
  end
end
