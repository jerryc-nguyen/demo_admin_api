require 'rails_helper'

RSpec.describe Reports::ViewFinanceReport::DashboardService, type: :module do
  let(:target_date) { Date.new(2026, 8, 10) }

  describe '.call' do
    it 'returns the chart options and metrics' do
      result = described_class.call(
        display_mode: 'week',
        target_date: target_date,
        value_types: ['pos_revenue', 'labour_cost'],
        compare_with_previous: false
      )

      expect(result).to be_a(Hash)
      expect(result).to have_key(:chart_options)
      expect(result).to have_key(:previous_chart_options)
      expect(result).to have_key(:metrics)
      expect(result[:previous_chart_options]).to be_nil
    end

    context 'when compare_with_previous is true' do
      it 'calculates previous date and returns previous_chart_options' do
        result = described_class.call(
          display_mode: 'week',
          target_date: target_date,
          value_types: ['pos_revenue'],
          compare_with_previous: true
        )

        expect(result[:previous_chart_options]).not_to be_nil
      end
    end
  end
end
