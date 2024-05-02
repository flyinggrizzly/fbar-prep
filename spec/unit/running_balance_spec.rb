require './spec/spec_helper'

require './lib/running_balance'
require './lib/account'

RSpec.describe FBARPrep::RunningBalance do
  describe '#highest_balance_date' do
    describe 'provided a date range' do
      it 'returns the highest balance within the date range' do
        out_of_range = Date.new(2020, 07, 21)
        range_begin = Date.new(2020, 07, 22)
        range_end = Date.new(2020, 07, 23)

        transactions = [
          transaction(out_of_range, 10_000.00),
          transaction(range_begin, 9_000.00),
          transaction(range_end, 9_087.00),
        ]

        balance = FBARPrep::RunningBalance.new(transactions)

        [:eod, :max].each do |strategy|
          expect(balance.highest_balance_date(strategy)).to eq(out_of_range)
          expect(balance.highest_balance_date(strategy, range_begin..range_end)).to eq(range_end)
        end
      end

      it 'returns nil if all transactions post date the range' do
        txn_date = Date.new(2021, 1, 1)
        early_range = (txn_date - 2.days)...(txn_date - 1.days)

        transactions = [transaction(txn_date, 1)]

        balance = described_class.new(transactions)

        [:eod, :max].each do |strategy|
          expect(balance.highest_balance_date(strategy, early_range)).to eq(nil)
        end
      end

      it 'returns the range begin date if all transactions precede the date range' do
        txn_date = Date.new(2021, 1, 1)

        range_begin = txn_date + 1.day
        later_range = range_begin...(txn_date + 4.days)

        transactions = [transaction(txn_date, 1)]

        balance = described_class.new(transactions)

        [:eod, :max].each do |strategy|
          expect(balance.highest_balance_date(strategy, later_range)).to eq(range_begin)
        end
      end
    end

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
