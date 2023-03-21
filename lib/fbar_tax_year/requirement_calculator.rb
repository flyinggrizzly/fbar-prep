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

        balances = (Date.new(year, 1, 1)..Date.new(year, 12, 31)).map do |date|
          {
            date:,
            eod_balance: accounts.map {|account| account.balance_on(date)}.compact.sum,
            max_balance: accounts.map {|account| account.balance_on(date, :max)}.compact.sum
          }
        end

        highest_eod = balances.max_by {|h| h[:eod_balance]}
        date_of_highest_eod_balance = highest_eod[:date]

        highest_max = balances.max_by {|h| h[:max_balance]}
        date_of_highest_max_balance = highest_max[:date]

        end_of_year = Date.new(year, 12, 31)

        data = [
          {
            'account' => nil,
            'year' => year,
            'fbar threshold' => fbar_year.combined_total_threshold,
            'highest combined eod balance' => highest_eod[:eod_balance],
            'date of highest combined eod balance' => strdate(date_of_highest_eod_balance),
            'highest combined max balance' => highest_max[:max_balance],
            'date of highest combined max balance' => strdate(date_of_highest_max_balance),

            'balance at eoy' => nil,
            'highest eod account balance' => nil,
            'highest max account balance' => nil,
            'bank address' => nil,
          }
        ]

        accounts.each do |account|
          data.push({
            'account' => account.handle,
            'year' => year,
            'fbar threshold' => nil,
            'highest combined eod balance' => nil,
            'date of highest combined eod balance' => nil,
            'highest combined max balance' => nil,
            'date of highest combined max balance' => nil,

            'balance at eoy' => account.balance_on(end_of_year),
            'highest eod account balance' => account.balance_on(date_of_highest_eod_balance),
            'highest max account balance' => account.balance_on(date_of_highest_max_balance, :max),
            'bank address' => account.address,
          })
        end

        data
      end

      def eod_active?
        [ :both, :eod ].include?(strategy)
      end

      def max_active?
        [ :both, :max ].include?(strategy)
      end

      def strdate(date)
        date.strftime('%Y-%m-%d')
      end
    end
  end
end

