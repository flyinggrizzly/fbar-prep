module FBARPrep
  class CheckSequentialityOfStatements
    def initialize(bank_account, clamp_from:, clamp_to:)
      @bank_account = bank_account
      @dups = []
      @top_or_tail_gaps = []
      @interstitial_gaps = []
      @clamp_from = clamp_from
      @clamp_to = clamp_to
    end

    attr_reader :bank_account, :top_or_tail_gaps, :interstitial_gaps, :dups, :clamp_from, :clamp_to

    Result = Struct.new(
      :bank_account,
      :duplicates,
      :mid_year_gaps,
      :beginning_or_end_of_year_gaps
    ) do
      def ok?
        duplicates.empty? && mid_year_gaps.empty? && beginning_or_end_of_year_gaps.empty?
      end
    end

    def perform
      dates = bank_account.statements.collect(&:first_transaction_date).sort
        .map {|d| d.strftime('%Y-%m')}
        .map {|d| d.split('-')}
        .map {|tuple| tuple.map(&:to_i)}

      dates_by_year = dates.group_by(&:first)

      dates_by_year.each do |year, dates|
        months = dates.map {|d| d[1]}.sort

        # If we've got a year, we're good
        next if months == all_months

        record_duplicates!(year, months)

        record_gaps!(year, months)
      end

      Result.new(bank_account, dups, interstitial_gaps, top_or_tail_gaps)
    end

    private

    def all_months
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    end

    def record_duplicates!(year, months)
      (months - months.uniq).each do |month|
        dups.push({
          bank: bank_account.provider,
          account: bank_account.handle,
          year:,
          month:
        })
      end
    end

    def record_gaps!(year, months)
      all_months.each do |month|
        next if months.include?(month)

        next if ignore?(year, month)

        register = if [1, 12].include?(month)
                     top_or_tail_gaps
                   else
                     last_month = month - 1
                     next_month = month + 1

                     if ([last_month, next_month] - months).empty?
                       interstitial_gaps
                     else
                       top_or_tail_gaps
                     end
                   end

        register.push({
          bank: bank_account.provider,
          account: bank_account.handle,
          year:,
          month:
        })
      end
    end

    def gap_register(current_month, months)
      return top_or_tail_gaps if current_month == 1
    end

    def ignore?(year, month)
      test_date = Date.new(year, month)

      too_old = test_date < clamp_from
      too_new = test_date > clamp_to

      too_old || too_new || future?(year, month)
    end

    def future?(year, month)
      Date.new(year, month) > Date.today
    end
  end
end
