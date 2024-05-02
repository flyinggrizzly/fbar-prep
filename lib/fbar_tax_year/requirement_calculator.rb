require 'money'

require './lib/currency/year_converter'

module FBARPrep
  module FBARTaxYear
    class RequirementCalculator
      REPORTING_THRESHOLD = ::Money.from_amount(10_000, "USD")

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

        end_of_year = Date.new(year, 12, 31)
        date_range = (Date.new(year, 1, 1)..end_of_year)

        return accounts.map do |account|
          # Check the last day of the year.
          #
          # If the account was opened during the year, there will be a balance.
          # If the account was opened after the single highest combined balance date, that will be nil, but we still
          # have to report the EOY balance.
          next unless account.balance_available?(end_of_year)

          max_balance, max_balance_date = account.max_balance_and_date(date_range)

          {
            'bank name' => account.full_provider_name,
            'bank address' => account.address,
            'account' => account.identifier,
            'account currency' => account.currency,
            'exchange rate to USD' => exchange_rate_to_usd(account.currency),
            'fbar threshold (USD)' => REPORTING_THRESHOLD.to_f,

            'maximum balance (local currency)' => float_or_nil(max_balance),
            'maximum balance (USD)' => float_or_nil(usd(max_balance)),
            'maximum balance date' => max_balance_date.to_s,

            'balance at eoy (local currency)' => float_or_nil(
              account.balance_on(end_of_year)
            ),
            'balance at eoy (USD)' => float_or_nil(
              usd(account.balance_on(end_of_year))
            ),
          }
        end.compact
      end

      def float_or_nil(value)
        return if value.nil?

        value.to_f
      end

      def usd(money)
        return if money.nil?

        currency_converter.convert(money)
      end

      def exchange_rate_to_usd(source_currency_code)
        return if source_currency_code.nil?

        currency_converter.rate_for(source_currency_code)
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

