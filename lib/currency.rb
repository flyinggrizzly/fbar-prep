require 'money'

require './lib/currency/bank_factory'

module FBARPrep
  module Currency
    extend self

    class UnconfiguredMoneyError < StandardError; end

    @@configured = false

    def configure!
      ::Money.locale_backend = :currency
      ::Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN

      @@configured = true
    end

    def from_float(float, currency)
      raise UnconfiguredMoneyError.new unless @@configured

      currency_exponent = ::Money::Currency.new(currency).exponent

      to_cents_factor = 10 ** currency_exponent

      ::Money.from_cents(
        (Float(float) * to_cents_factor),
        currency
      )
    end
  end
end
