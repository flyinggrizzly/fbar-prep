require 'money'

require './lib/currency/year_converter'

module FBARPrep
  class InterestSummaryCalculator
    def initialize(year:, accounts:, outpath:)
      @year = year
      end_of_year = Date.new(@year, 12, 31)
      @date_range = (Date.new(@year, 1, 1)..end_of_year)
      @accounts = accounts
      @outpath = outpath
      @currency_converter = Currency::YearConverter.new(
        @accounts.map(&:currency),
        @year
      )
    end

    def generate_report!
      interest_summaries.tap do |summaries|
        csv = CSV.generate do |c|
          # headers
          c << ['total interest', *summaries.first.keys]

          total_interest = summaries.filter_map { |s| s['interest in USD'] }
            .sum(0)

          # overall summary row
          c << [total_interest, *Array.new(summaries.first.keys.size)]

          summaries.each do |s|
            values = s.values.map do |v|
              next '-' if v.nil?

              v
            end

            c << [nil, *values]
          end
        end

        File.write(path, csv)
      end
    end

    def interest_summaries
      @accounts.filter_map do |account|
        next unless account.open_in?(@date_range)

        interest_transactions = account.interest_transactions(@date_range)

        next unless interest_transactions.any?

        interest = interest_transactions.map(&:amount).inject(Money.new(0, 'USD')) do |sum, amount|
          sum + usd(amount)
        end

        {
          'bank name' => account.full_provider_name,
          'bank address' => account.address,
          'account' => account.identifier,
          'account currency' => account.currency,
          'exchange rate to USD' => exchange_rate_to_usd(account.currency),
          'interest in USD' => float_or_nil(interest),
        }
      end
    end

    private

    attr_reader :currency_converter

    def path
      name_elems = [
        "annual_interest_summary",
        "year=#{@year}",
        "generated_at=#{Time.now.strftime('%Y-%m-%dT%H-%M-%S')}",
      ]

      ensure_output_folder

      File.join("./#{@outpath}", "#{name_elems.join('__')}.csv")
    end

    def float_or_nil(value)
      return if value.nil?

      value.to_f
    end

    def usd(money)
      return if money.nil?

      currency_converter.convert(money)
    end

    def exchange_rate_to_usd(source_currency_code)
      return if source_currency_code.nil?

      currency_converter.rate_for(source_currency_code)
    end

    def ensure_output_folder
      Dir.mkdir("./#{@outpath}") unless Dir.exist?("./#{@outpath}")
    end
  end
end
