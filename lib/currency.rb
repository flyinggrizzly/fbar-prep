require 'money'

require './lib/money/bank_factory'

module FBARPrep
  module Currency
    extend self

    def from_float_on(float, currency, year)
      from_float(float, currency, bank: BankFactory.for(currency, year))
    end

    def from_float(float, currency, bank: nil)
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
