FactoryBot.define do
  factory :daily_finance_report do
    date { Faker::Date.between(from: 30.days.ago, to: Date.today) }
    value_type { DailyFinanceReport::VALID_VALUE_TYPES.sample }
    value { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  end
end
