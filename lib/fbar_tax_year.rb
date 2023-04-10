require './lib/fatca/threshold'

module FBARPrep
  module FBARTaxYear
    extend self

    Year = Struct.new(:year, :combined_total_threshold)

    def for(year)
      Year.new(year, FATCA.reporting_threshold)
    end
  end
end
