require 'yaml'

require './lib/data'

module FBARPrep
  module FBARTaxYear
    extend self

    Year = Struct.new(:year, :combined_total_threshold)

    def for(year)
      fatca_data = YAML.load_file('./data/fatca.yml')

      Year.new(year, Data.fatca_thresholds.fetch(year))
    end
  end
end
