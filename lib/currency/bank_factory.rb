require 'money'
require './lib/data'
require './lib/currency/bank_factory/errors'

module FBARPrep
  module Currency
    module BankFactory
      extend self

      def for(currencies, year)
        irs_rates = Array(currencies).uniq.map {|currency|
          irs_rate = Data.irs_exchange_rate_for(currency, year)

          raise MissingRateError.new(year, currency) unless irs_rate.ok?

          rate = Float(irs_rate.value)

          raise InvalidRateError.new(currency, year, rate) unless rate > 0

          [currency, rate]
        }

        ::Money::Bank::VariableExchange.new(::Money::RatesStore::Memory.new).tap do |bank|
          irs_rates.each do |currency, rate|
            bank.add_rate('usd', currency, rate)
            bank.add_rate(currency, 'usd', 1 / rate)
          end
        end
      end
    end
  end
end
