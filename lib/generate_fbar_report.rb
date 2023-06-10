require './lib/fbar_tax_year/requirement_calculator'

module FBARPrep
  class GenerateFBARReport
    def initialize(fbar_year, accounts, strategy:)
      @fbar_year = fbar_year
      @year = fbar_year.year
      @accounts = accounts
      @strategy = strategy
      @year_calculator = FBARTaxYear::RequirementCalculator.new(@fbar_year, accounts, strategy:)
    end

    attr_reader :fbar_year,
      :year,
      :accounts,
      :year_calculator,
      :strategy

    def perform
      data = year_calculator.report_data

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

      File.write(path, csv)
    end

    private

    def path
      path_elems = [
        "fbar_report",
        "year=#{year}",
        "strategy=#{strat}",
        "generated_at=#{Time.now.strftime('%Y-%m-%dT%H-%M-%S')}",
      ]

      ensure_output_folder

      File.join('./output', "#{path_elems.join('__')}.csv")
    end

    def strat
      strategy == :both ? "[eod,max]" : strategy.to_s
    end

    def ensure_output_folder
      Dir.mkdir('./output') unless Dir.exist?('./output')
    end
  end
end
