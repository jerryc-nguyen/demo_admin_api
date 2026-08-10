class CreateDailyFinanceReports < ActiveRecord::Migration[7.1]
  def change
    create_table :daily_finance_reports do |t|
      t.date :date, null: false
      t.string :value_type, null: false
      t.decimal :value, precision: 15, scale: 2, default: 0.0, null: false

      t.timestamps
    end

    add_index :daily_finance_reports, [:date, :value_type], unique: true
  end
end
