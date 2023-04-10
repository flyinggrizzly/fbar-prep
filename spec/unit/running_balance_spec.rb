require './spec/spec_helper'

require './lib/running_balance'
require './lib/account'

RSpec.describe FBARPrep::RunningBalance do
  describe '#highest_balance_date' do
    context 'strategy is :max' do
      it 'returns the right date' do
        transactions = [
          transaction(Date.new(2020, 07, 21), 10_000.00),
          transaction(Date.new(2020, 07, 21), 9_000.00),
          transaction(Date.new(2020, 07, 23), 9_087.00),
        ]

        balance = FBARPrep::RunningBalance.new(transactions)

        expect(balance.highest_balance_date(:max)).to eq(Date.new(2020, 07, 21))
      end
    end

    context 'strategy is :eod' do
      it 'returns the right date' do
        transactions = [
          transaction(Date.new(2020, 01, 01), 10_000.00),
          transaction(Date.new(2020, 01, 01), 9_000.00),
          transaction(Date.new(2020, 01, 02), 9_100.00),
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
        transaction(date, 10_000.00, 'gbp'),
        transaction(date, 9_000.00, 'gbp'),
      ]
    }
    let(:balance) { FBARPrep::RunningBalance.new(transactions) }

    context 'strategy is :max' do
      let(:strategy) { :max }

      it 'returns the right balance' do
        expect(balance.balance_on(date, strategy)).to eq(money(10_000.00, 'gbp'))
      end

      context 'date does not have any transactions' do
        let(:requested_date) { Date.new(2020, 7, 22) }

        it 'returns the most recent EOD value' do
          expect(balance.balance_on(requested_date, strategy)).to eq(money(9_000.00, 'gbp'))
        end
      end
    end

    context 'strategy is :eod' do
      let(:strategy) { :eod }

      it 'returns the right balance' do
        expect(balance.balance_on(date, strategy)).to eq(money(9_000.00, 'gbp'))
      end
    end
  end

  def transaction(date, balance, currency = 'gbp')
    FBARPrep::Statement::Transaction.new(
      date:,
      balance: money(balance, currency)
    )
  end

  def money(balance, currency)
    FBARPrep::Currency.from_float(balance, currency)
  end
end
