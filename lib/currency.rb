require 'money'

require './lib/currency/bank_factory'

module FBARPrep
  module Currency
    extend self

    class UnconfiguredMoneyError < StandardError; end

    @@configured = false

    def configure!
      ::Money.locale_backend = :currency

      @@configured = true
    end

    def from_float_on(float, currency, year)
      raise UnconfiguredMoneyError.new unless @@configured

      from_float(float, currency, bank: BankFactory.for(currency, year))
    end

    def from_float(float, currency, bank: nil)
      raise UnconfiguredMoneyError.new unless @@configured

      currency_exponent = ::Money::Currency.new(currency).exponent

      to_cents_factor = 10 ** currency_exponent

      ::Money.from_cents(
        (Float(float) * to_cents_factor),
        currency,
        bank:
      )
    end
  end
end
