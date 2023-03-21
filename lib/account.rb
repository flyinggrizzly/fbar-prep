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
      :opening_date,
      :address,
      :full_provider_name

    attr_reader :statements, :running_balance

    def balance_on(date, strategy = :eod)
      running_balance.balance_on(date, strategy)
    end

    def highest_balance_date(strategy = :eod)
      running_balance.highest_balance_date(strategy)
    end

    def transactions
      statements.flat_map(&:transactions)
    end

    private

    def prepare_balance!
      @running_balance = RunningBalance.new(statements.flat_map(&:transactions))
    end

    def load_statements!
      statement_filenames = Data.children(provider, handle)

      @statements ||= statement_filenames.map {|filename| Statement.new(filename:, account: self)}
        .filter(&:has_transactions?)
        .sort_by(&:first_transaction_date)
    end

    class PensionAccount < Account
      def_delegators :@account_record, :policy_number
    end

    class BankAccount < Account
      def_delegators :@account_record,
        :number,
        :sort_code,
        :closing_date,
        :joint

      def bank_name
        provider
      end
    end
  end
end
