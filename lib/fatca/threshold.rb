module FBARPrep
  module FATCA
    extend self

    def reporting_threshold
      ::Money.from_amount(10_000, "USD")
    end
  end
end
