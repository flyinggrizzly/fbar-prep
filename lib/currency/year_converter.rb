require 'money'
require './lib/data'
require './lib/currency/bank_factory/errors'

module FBARPrep
  module Currency
    class YearConverter
      def initialize(currencies, year)
        @bank = Currency::BankFactory.for(currencies, year)
      end

      attr_reader :bank

      def convert(money, to_currency = 'usd')
        bank.exchange_with(money, to_currency)
      end

      def rate_for(source_currency)
        bank.get_rate(source_currency, 'usd')
      end
    end
  end
end
