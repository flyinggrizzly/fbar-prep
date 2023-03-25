require 'money'
require './lib/data'

module FBARPrep
  module Currency
    module BankFactory
      extend self

      class InvalidRateError < StandardError; end

      def for(currency, year)
        irs_rate = Data.irs_exchange_rate_for(currency, year)

        return unless irs_rate.ok?

        rate = Float(irs_rate.value)

        raise InvalidRateError.new(currency, year, rate) unless rate > 0

        ::Money::Bank::VariableExchange.new(::Money::RatesStore::Memory.new).tap do |bank|
          bank.add_rate('usd', currency, rate)
          bank.add_rate(currency, 'usd', 1 / rate)
        end
      end
    end
  end
end
