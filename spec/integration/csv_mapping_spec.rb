require './lib/fbar_prep'
require './lib/data'

RSpec.describe "CSV mapping and balance reading" do
  before(:each) {
    allow(FBARPrep::Data).to receive(:account_data_filename) { 'accounts.demo.yml' }
  }

  context 'with a complex mapping' do
    let(:account) { FBARPrep.account('demo-bank-daily-1234') }

    describe 'verifying mappings and data computations' do
      let(:transactions) { account.transactions }

      it 'handles non-numeric date formats' do
        expect(transactions.first.date).to eq(Date.new(2021, 6, 1))
      end

      it 'handles prefixed concatenation' do
        expect(transactions.first.details).to eq(
          "payee= | payer=Mike"
        )
        expect(transactions[1].details).to eq(
          "payee= | payer= | #killingit"
        )
      end

      it 'handles composed first not null and multiplication' do
        expect(transactions.first.amount).to eq(money(101.01))
        expect(transactions.first.balance).to eq(money(101.01))

        expect(transactions[1].amount).to eq(money(-35.10))
        expect(transactions[1].balance).to eq(money(65.91))
      end
    end
  end

  context 'with a simple mapping' do
    let(:account) { FBARPrep.account('demo-bank-savings-5678') }

    context 'with the `:max` strategy' do
      it 'returns the highest balance on the day' do
        expect(account.balance_on(Date.new(2021, 12, 31), :max)).to eq(money(2100.01))
      end

      it 'returns the latest eod balance on a day without transactions' do
        expect(account.balance_on(Date.new(2022, 01, 01), :max)).to eq(money(2000.00))
      end
    end

    context 'with the `:eod` strategy' do
      it 'returns the eod balance on the same date' do
        expect(account.balance_on(Date.new(2021, 12, 31), :eod)).to eq(money(2000.00))
      end

      it 'returns the previous eod balance on following dates' do
        expect(account.balance_on(Date.new(2022, 01, 01), :eod)).to eq(money(2000.00))
      end
    end
  end

  def money(val, currency = 'gbp')
    Money.from_amount(val, currency)
  end
end
