require 'yaml'
require 'date'
require 'forwardable'

require_relative './data'
require_relative './statement'
require_relative './running_balance'

module FBARPrep
  class Account
    extend Forwardable

    class << self
      def all
        Data.account_records.map {|ar| Account.for(ar.handle)}
      end

      def for(handle)
        account_record = Data.account_records.detect {|ar| ar.handle == handle}

        case account_record.type
        when 'current', 'savings'
          BankAccount.new(account_record)
        when 'pension'
          PensionAccount.new(account_record)
        else
          raise "can't build accounts for type #{account_record.type}"
        end
      end
    end

    def initialize(account_record)
      @account_record = account_record

      load_statements!
      prepare_balance!
    end

    def_delegators :@account_record,
      :handle,
      :provider,
      :currency,
      :opening_date,
      :closing_date,
      :address,
      :full_provider_name

    attr_reader :statements, :running_balance

    def open_in?(date_range)
      opened_in_time = opening_date < date_range.end
      still_open = closing_date.nil? || closing_date > date_range.begin

      opened_in_time && still_open
    end

    def balance_on(date, strategy = :eod)
      running_balance.balance_on(date, strategy)
    end

    def highest_balance_date(strategy = :eod, date_range = nil)
      running_balance.highest_balance_date(strategy, date_range)
    end

    def max_balance_and_date(date_range = nil)
      date = highest_balance_date(:max, date_range)

      [balance_on(date, :max), date]
    end

    def transactions
      statements.flat_map(&:transactions)
    end

    def balance_available?(date)
      running_balance.any_data_for?(date)
    end

    private

    def prepare_balance!
      @running_balance = RunningBalance.new(transactions)
    end

    def load_statements!
      statement_filenames = Data.children(provider, handle)

      @statements ||= statement_filenames.map {|filename| Statement.new(filename:, account: self)}
        .filter(&:has_transactions?)
        .sort_by(&:first_transaction_date)
    end

    class PensionAccount < Account
      def_delegators :@account_record, :policy_number

      def identifier
        policy_number
      end
    end

    class BankAccount < Account
      def_delegators :@account_record,
        :number,
        :sort_code,
        :joint

      def identifier
        "#{number}/#{sort_code}"
      end

      def bank_name
        provider
      end
    end
  end
end
