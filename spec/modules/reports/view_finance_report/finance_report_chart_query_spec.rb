require 'rails_helper'

RSpec.describe Reports::ViewFinanceReport::FinanceReportChartQuery, type: :module do
  let(:target_date) { Date.new(2026, 8, 10) }
  let(:strategy) { Reports::ChartOptions::StrategyFactory.for(:week, target_date) }

  describe '.call' do
    it 'returns points for all 7 days of the week' do
      result = described_class.call(strategy)
      expect(result.size).to eq(7)
      expect(result.first[:period]).to eq(Date.new(2026, 8, 10)) # Monday
      expect(result.last[:period]).to eq(Date.new(2026, 8, 16))  # Sunday
    end

    it 'fills missing periods with 0' do
      result = described_class.call(strategy)
      result.each do |point|
        expect(point[:pos_revenue]).to eq(0)
        expect(point[:eatclub_revenue]).to eq(0)
        expect(point[:labour_cost]).to eq(0)
      end
    end

    it 'aggregates existing records correctly' do
      create(:daily_finance_report, date: Date.new(2026, 8, 12), value_type: 'pos_revenue', value: 150.0)
      create(:daily_finance_report, date: Date.new(2026, 8, 12), value_type: 'labour_cost', value: 50.0)

      result = described_class.call(strategy)
      target_point = result.find { |p| p[:period] == Date.new(2026, 8, 12) }

      expect(target_point[:pos_revenue].to_f).to eq(150.0)
      expect(target_point[:labour_cost].to_f).to eq(50.0)
      expect(target_point[:eatclub_revenue].to_f).to eq(0.0)
    end
  end
end
