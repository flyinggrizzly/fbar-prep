require './lib/fbar_tax_year/requirement_calculator'

module FBARPrep
  class GenerateFBARReport
    def initialize(fbar_years, accounts, strategy:)
      @fbar_years = fbar_years
      @years = fbar_years.map(&:year)
      @accounts = accounts
      @strategy = strategy
      @year_calculators = @fbar_years.map {|year|
        FBARTaxYear::RequirementCalculator.new(year, accounts, strategy:)
      }
    end

    attr_reader :fbar_years,
      :years,
      :accounts,
      :year_calculators,
      :strategy

    def perform
      data = year_calculators.map(&:report_data)

      csv = CSV.generate do |c|
        # headers
        c << data.first.keys

        data.each do |d|
          values = d.values.map do |v|
            next '-' if v.nil?

            v
          end

          c << values
        end
      end

      strat = strategy == :both ? "[eod,max]" : strategy.to_s
      timeframe = years.size > 1 ? "[#{years.join(',')}]" : years.first

      path_elems = [
        "fbar_report",
        "years=#{timeframe}",
        "strategy=#{strat}",
        "generate=#{Time.now.strftime('%Y-%m-%dT%H-%M-%S')}",
      ]

      path = File.join('./output', "#{path_elems.join('__')}.csv")

      File.write(path, csv)
    end
  end
end
