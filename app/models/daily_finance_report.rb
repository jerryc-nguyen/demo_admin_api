class DailyFinanceReport < ApplicationRecord
  VALID_VALUE_TYPES = %w[pos_revenue eatclub_revenue labour_cost].freeze

  validates :date, presence: true
  validates :value, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :value_type, presence: true,
                         inclusion: { in: VALID_VALUE_TYPES, message: "%{value} is not a valid value_type" },
                         uniqueness: { scope: :date, message: "already exists for this date" }
end
