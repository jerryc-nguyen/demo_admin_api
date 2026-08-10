# Design Spec: Finance Reports API for ECharts

This design document outlines the implementation of a Rails API endpoint that provides weekly financial statistics (POS revenue, EatClub revenue, and labor cost) formatted specifically for Apache ECharts.

## 1. Objectives

- Provide a single endpoint to fetch weekly financial data.
- Accept a `current_date` parameter to retrieve statistics for the week containing that date.
- Return data in a structure directly consumable by ECharts stacked/unstacked bar charts.

## 2. Database Schema & Model

### Database Migration
We will create a `daily_finance_reports` table with fields for date, type of value, and the decimal value.

```ruby
class CreateDailyFinanceReports < ActiveRecord::Migration[7.1]
  def change
    create_table :daily_finance_reports do |t|
      t.date :date, null: false
      t.string :value_type, null: false
      t.decimal :value, precision: 15, scale: 2, default: 0.0, null: false

      t.timestamps
    end

    # Enforce uniqueness of value_type per day
    add_index :daily_finance_reports, [:date, :value_type], unique: true
  end
end
```

### Rails Model (`app/models/daily_finance_report.rb`)
```ruby
class DailyFinanceReport < ApplicationRecord
  VALID_VALUE_TYPES = %w[pos_revenue eatclub_revenue labour_cost].freeze

  validates :date, presence: true
  validates :value, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :value_type, presence: true,
                         inclusion: { in: VALID_VALUE_TYPES, message: "%{value} is not a valid value_type" },
                         uniqueness: { scope: :date, message: "already exists for this date" }
end
```

## 3. Routing & Controller

### Route Configuration (`config/routes.rb`)
```ruby
Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :reports do
    resources :finance_reports, only: [:index]
  end
end
```

### Controller (`app/controllers/reports/finance_reports_controller.rb`)
```ruby
module Reports
  class FinanceReportsController < ApplicationController
    def index
      target_date = parse_date_param(params[:current_date])
      start_date = target_date.beginning_of_week
      end_date = start_date.end_of_week

      reports = Reports::ViewFinanceReport::Queries::FinanceReportsQuery.call(start_date, end_date)
      render json: Reports::ViewFinanceReport::Services::EchartReportBuilder.new(start_date, reports).call
    end

    private

    def parse_date_param(date_param)
      return Date.current if date_param.blank?
      Date.parse(date_param)
    rescue ArgumentError
      Date.current
    end
  end
end
```

### Feature Query (`app/modules/reports/view_finance_report/queries/finance_reports_query.rb`)
```ruby
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
```

## 4. ECharts Builder (`app/modules/reports/view_finance_report/services/echart_report_builder.rb`)

Constructs the ECharts series payload. `pos_revenue` and `eatclub_revenue` are stacked under `'Revenue'`, while `labour_cost` is a separate bar.

```ruby
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
```

## 5. Verification Plan

### Manual Verification
1. Run migrations and seed data in `db/seeds.rb` with sample financial records for testing.
2. Launch the Rails local server.
3. Access `/reports/finance_reports?current_date=2026-08-07` and verify the JSON response payload.
