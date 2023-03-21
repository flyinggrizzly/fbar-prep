require 'money'

module FBARPrep
  module Currency
    module BankFactory
      extend self

      def for(currency, year)
        irs_rate = Data.irs_exchange_rate_for(currency, year)

        ::Money::Bank::VariableExchange.new(::Money::RatesStore::Memory.new).tap do |bank|
          bank.add_rate('usd', currency, irs_rate)
        end
      end
    end
  end
end
