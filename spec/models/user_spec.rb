require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to be_valid }

    it 'requires email' do
      subject.email = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:email]).to include("can't be blank")
    end

    it 'requires unique email' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('has already been taken')
    end

    it 'requires valid email format' do
      invalid_emails = ['plainaddress', '#@%^%#$@#$@#.com', '@example.com', 'Joe Smith <email@example.com>']
      invalid_emails.each do |email|
        subject.email = email
        expect(subject).not_to be_valid
      end
    end

    it 'requires password to be at least 6 characters' do
      subject.password = '12345'
      expect(subject).not_to be_valid
      expect(subject.errors[:password]).to include('is too short (minimum is 6 characters)')
    end
  end

  describe 'password security' do
    it 'authenticates correct password' do
      user = create(:user, password: 'password123')
      expect(user.authenticate('password123')).to eq(user)
    end

    it 'rejects incorrect password' do
      user = create(:user, password: 'password123')
      expect(user.authenticate('wrongpassword')).to be_falsy
    end
  end
end
