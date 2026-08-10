# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing daily reports
DailyFinanceReport.destroy_all

# Monday to Sunday sample data for the week of 2026-08-10
start_date = Date.parse("2026-08-10")
(0..6).each do |i|
  date = start_date + i
  DailyFinanceReport.create!(date: date, value_type: "pos_revenue", value: 100.0 + (i * 10))
  DailyFinanceReport.create!(date: date, value_type: "eatclub_revenue", value: 50.0 + (i * 5))
  DailyFinanceReport.create!(date: date, value_type: "labour_cost", value: 40.0 + (i * 2))
end
