module FBARPrep
  module Currency
    module BankFactory
      class InvalidRateError < StandardError
        def initialize(year, currency, rate)
          super(
            "Invalid rate #{rate} for currency #{currency} in year #{year}"
          )
        end
      end

      class MissingRateError < StandardError
        def initialize(year, currency)
          super(
            "Missing rate for currency #{currency} in year #{year}"
          )
        end
      end
    end
  end
end
