require 'money'

require './lib/currency/year_converter'

module FBARPrep
  module FBARTaxYear
    class RequirementCalculator
      REPORTING_THRESHOLD = ::Money.from_amount(10_000, "USD")

      class InconsistentDataError < StandardError; end

      def initialize(fbar_year, accounts, strategy: :both)
        raise 'bad strategy' unless [ :both, :eod, :max ].include?(strategy)

        @fbar_year = fbar_year
        @accounts = accounts
        @strategy = strategy
        @currency_converter = Currency::YearConverter.new(@accounts.map(&:currency), @fbar_year.year)
      end

      attr_reader :fbar_year, :accounts, :strategy, :currency_converter

      def report_data
        year = fbar_year.year

        balances = (Date.new(year, 1, 1)..Date.new(year, 12, 31)).map do |date|
          {
            date:,
            eod_balance: sum_balances(accounts.map {|account| account.balance_on(date)}.compact),
            max_balance: sum_balances(accounts.map {|account| account.balance_on(date, :max)}.compact)
          }
        end

        highest_eod = balances.max_by {|h| h[:eod_balance]}
        date_of_highest_eod_balance = highest_eod[:date]

        highest_max = balances.max_by {|h| h[:max_balance]}
        date_of_highest_max_balance = highest_max[:date]

        end_of_year = Date.new(year, 12, 31)

        data = [
          {
            'year' => year,
            'bank name' => nil,
            'bank address' => nil,
            'account' => nil,
            'account currency' => nil,
            'fbar threshold (USD)' => REPORTING_THRESHOLD.to_f,
            'highest combined eod balance' => float_or_nil(highest_eod[:eod_balance]),
            'date of highest combined eod balance' => strdate(date_of_highest_eod_balance),
            'highest combined max balance' => float_or_nil(highest_max[:max_balance]),
            'date of highest combined max balance' => strdate(date_of_highest_max_balance),

            'balance at eoy (local currency)' => nil,
            'balance at eoy (USD)' => nil,
            'highest eod account balance (local currency)' => nil,
            'highest eod account balance (USD)' => nil,
            'highest max account balance (local currency)' => nil,
            'highest max account balance (USD)' => nil,
          }
        ]

        accounts.each do |account|
          data.push({
            'year' => year,
            'bank name' => account.full_provider_name,
            'bank address' => account.address,
            'account' => account.identifier,
            'account currency' => account.currency,
            'fbar threshold (USD)' => nil,
            'highest combined eod balance' => nil,
            'date of highest combined eod balance' => nil,
            'highest combined max balance' => nil,
            'date of highest combined max balance' => nil,

            'balance at eoy (local currency)' => float_or_nil(
              account.balance_on(end_of_year)
            ),
            'balance at eoy (USD)' => float_or_nil(
              usd(account.balance_on(end_of_year))
            ),
            'highest eod account balance (local currency)' => float_or_nil(
              account.balance_on(date_of_highest_eod_balance)
            ),
            'highest eod account balance (USD)' => float_or_nil(
              usd(account.balance_on(date_of_highest_eod_balance))
            ),
            'highest max account balance (local currency)' => float_or_nil(
              account.balance_on(date_of_highest_max_balance, :max)
            ),
            'highest max account balance (USD)' => float_or_nil(
              usd(account.balance_on(date_of_highest_max_balance, :max))
            ),
          })
        end

        raise InconsistentDataError.new unless data.map(&:keys).uniq.size == 1

        data
      end

      def float_or_nil(value)
        return if value.nil?

        value.to_f
      end

      def usd(money)
        return if money.nil?

        currency_converter.convert(money)
      end

      def eod_active?
        [ :both, :eod ].include?(strategy)
      end

      def max_active?
        [ :both, :max ].include?(strategy)
      end

      def strdate(date)
        date.strftime('%Y-%m-%d')
      end

      def sum_balances(balances)
        balances.compact.inject(Money.new(0, 'usd')) do |sum, balance|
          sum + usd(balance)
        end
      end
    end
  end
end

