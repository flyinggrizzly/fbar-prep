require './spec/spec_helper'

require './lib/running_balance'
require './lib/account'

RSpec.describe FBARPrep::RunningBalance do
  describe '#highest_balance_date' do
    context 'strategy is :max' do
      it 'returns the right date' do
        transactions = [
          FBARPrep::Statement::Transaction.new(date: Date.new(2020, 07, 21), balance: 10_000.00),
          FBARPrep::Statement::Transaction.new(date: Date.new(2020, 07, 21), balance: 9_000.00),
          FBARPrep::Statement::Transaction.new(date: Date.new(2020, 07, 23), balance: 9_087.00),
        ]

        balance = FBARPrep::RunningBalance.new(transactions)

        expect(balance.highest_balance_date(:max)).to eq(Date.new(2020, 07, 21))
      end
    end

    context 'strategy is :eod' do
      it 'returns the right date' do
        transactions = [
          FBARPrep::Statement::Transaction.new(date: Date.new(2020, 01, 01), balance: 10_000.00),
          FBARPrep::Statement::Transaction.new(date: Date.new(2020, 01, 01), balance: 9_000.00),
          FBARPrep::Statement::Transaction.new(date: Date.new(2020, 01, 02), balance: 9_100.00),
        ]

        balance = FBARPrep::RunningBalance.new(transactions)

        expect(balance.highest_balance_date(:eod)).to eq(Date.new(2020, 01, 02))
      end
    end
  end

  describe '#balance_on' do
    let(:date) { Date.new(2020, 7, 21) }
    let(:transactions) {
      [
        FBARPrep::Statement::Transaction.new(date: Date.new(2020, 07, 21), balance: 10_000.00),
        FBARPrep::Statement::Transaction.new(date: Date.new(2020, 07, 21), balance: 9_000.00),
      ]
    }
    let(:balance) { FBARPrep::RunningBalance.new(transactions) }

    context 'strategy is :max' do
      let(:strategy) { :max }

      it 'returns the right balance' do
        expect(balance.balance_on(date, strategy)).to eq(10_000.00)
      end

      context 'date does not have any transactions' do
        let(:date) { Date.new(2020, 7, 22) }

        it 'returns the most recent EOD value' do
          expect(balance.balance_on(date, strategy)).to eq(9_000.00)
        end
      end
    end

    context 'strategy is :eod' do
      let(:strategy) { :eod }

      it 'returns the right balance' do
        expect(balance.balance_on(date, strategy)).to eq(9_000.00)
      end
    end
  end
end
