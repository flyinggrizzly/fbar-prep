module FBARPrep
  class RunningBalance
    def initialize(transactions)
      @transactions = transactions
      @known_dates = @transactions.map(&:date).uniq
    end

    attr_reader :transactions

    def balance_on(date, strategy = :eod)
      if strategy == :eod
        eod_balance_on(date)
      elsif strategy == :max
        return eod_balance_on(date) unless concrete_data_for?(date)

        max_balance_on(date)
      else
        raise 'unknown strategy'
      end
    end

    def highest_balance_date(strategy = :eod, date_range = nil)
      if strategy == :eod
        date_of_max_eod_balance(date_range)
      elsif strategy == :max
        date_of_max_balance(date_range)
      else
        raise 'unknown strategy'
      end
    end

    private

    attr_reader :known_dates

    def eod_balance_on(date)
      return if transactions.empty?
      return if transactions.first.date > date

      transactions.filter {|t| t.date <= date}.last.balance
    end

    def max_balance_on(date)
      return if transactions.empty?
      return if transactions.first.date > date

      transactions.filter {|t| t.date == date}.map(&:balance).max
    end

    def date_of_max_eod_balance(date_range)
      candidates = transactions

      candidates = transactions.filter {|txn| date_range.include?(txn.date)} if date_range

      candidates.group_by(&:date).values.flat_map(&:last).max_by(&:balance).date
    end

    def date_of_max_balance(date_range)
      candidates = transactions

      candidates = transactions.filter {|txn| date_range.include?(txn.date)} if date_range

      candidates.max_by(&:balance).date
    end

    def concrete_data_for?(date)
      known_dates.include?(date)
    end
  end
end

