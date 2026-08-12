require 'rails_helper'

RSpec.describe DailyFinanceReport, type: :model do
  describe 'validations' do
    subject { build(:daily_finance_report) }

    it { is_expected.to be_valid }

    it 'requires date' do
      subject.date = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:date]).to include("can't be blank")
    end

    it 'requires value' do
      subject.value = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:value]).to include("can't be blank")
    end

    it 'requires value to be greater than or equal to 0' do
      subject.value = -1.0
      expect(subject).not_to be_valid
      expect(subject.errors[:value]).to include('must be greater than or equal to 0')
    end

    it 'requires value_type' do
      subject.value_type = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:value_type]).to include("can't be blank")
    end

    it 'only allows valid value_types' do
      subject.value_type = 'invalid_type'
      expect(subject).not_to be_valid
      expect(subject.errors[:value_type]).to include('invalid_type is not a valid value_type')
    end

    it 'enforces uniqueness of value_type scoped to date' do
      existing = create(:daily_finance_report, date: Date.today, value_type: 'pos_revenue')
      duplicate = build(:daily_finance_report, date: Date.today, value_type: 'pos_revenue')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:value_type]).to include('already exists for this date')
    end
  end
end
