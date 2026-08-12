# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing daily reports
DailyFinanceReport.destroy_all

# Recent 3 months of sample data
start_date = Date.today - 3.months
(0..92).each do |i|
  date = start_date + i
  
  # Weekly seasonality multiplier (wday: 0 = Sunday, 1 = Monday, ..., 6 = Saturday)
  wday_multiplier = case date.wday
                    when 5, 6    # Friday, Saturday (Peak weekend traffic)
                      rand(1.5..1.9)
                    when 0       # Sunday (Decent weekend spillover)
                      rand(1.1..1.3)
                    when 1       # Monday (Typically the slowest day)
                      rand(0.6..0.8)
                    else         # Tue, Wed, Thu (Standard weekdays)
                      rand(0.85..1.1)
                    end

  # Generate random but realistic base numbers and apply seasonality
  base_pos = rand(1500.0..2200.0)
  pos_revenue = (base_pos * wday_multiplier).round(2)

  base_eatclub = rand(250.0..450.0)
  eatclub_revenue = (base_eatclub * wday_multiplier).round(2)

  # Labour cost modeled as ~25-32% of total revenue, with a fixed daily baseline minimum
  total_revenue = pos_revenue + eatclub_revenue
  labour_cost = ([400.0, total_revenue * rand(0.25..0.32)].max).round(2)

  DailyFinanceReport.create!(date: date, value_type: "pos_revenue", value: pos_revenue)
  DailyFinanceReport.create!(date: date, value_type: "eatclub_revenue", value: eatclub_revenue)
  DailyFinanceReport.create!(date: date, value_type: "labour_cost", value: labour_cost)
end
