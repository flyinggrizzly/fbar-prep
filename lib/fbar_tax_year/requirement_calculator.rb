module FBARPrep
  module FBARTaxYear
    class RequirementCalculator
      def initialize(fbar_year, accounts, strategy: :both)
        raise 'bad strategy' unless [ :both, :eod, :max ].include?(strategy)

        @fbar_year = fbar_year
        @accounts = accounts
        @strategy = strategy
      end

      attr_reader :fbar_year, :accounts, :strategy

      def report_data
        year = fbar_year.year

        balances_by_date = (Date.new(year, 1, 1)..Date.new(year, 12, 31)).map do |date|
          [
            date,
            accounts.map {|a| a.balance_on(date)}.compact.sum,
            accounts.map {|a| a.balance_on(date, :max)}.compact.sum,
          ]
        end

        highest_eod = balances_by_date.max_by {|t| t[1]}
        highest_eod_date = highest_eod.first
        highest_eod_balance = highest_eod[1]

        highest_max = balances_by_date.max_by {|t| t[2]}
        highest_max_date = highest_max.first
        highest_max_balance = highest_max[2]

        hash = {
          year:,
          fbar_threshold_amount_in_pounds: fbar_year.combined_total_threshold,
        }

        if eod_active?
          hash = hash.merge({
            combined_total_using_eod_balance: highest_eod_balance,
            date_of_combined_total_using_eod_balance: highest_eod_date,
          })
        end

        if max_active?
          hash = hash.merge({
            highest_combined_total_using_highest_balance_in_day: highest_max_balance,
            date_of_highest_combined_total_using_highest_balance_in_day: highest_max_balance,
          })
        end

        accounts.each do |account|
          eod_key = "#{account.handle}_eod_balance_on_#{highest_eod_date.iso8601}"
          max_key = "#{account.handle}_max_balance_on_#{highest_max_date.iso8601}"

          hash[eod_key] = account.balance_on(highest_eod_date) if eod_active?
          hash[max_key] = account.balance_on(highest_max_date) if max_active?
        end

        hash
      end

      def eod_active?
        [ :both, :eod ].include?(strategy)
      end

      def max_active?
        [ :both, :max ].include?(strategy)
      end
    end
  end
end

