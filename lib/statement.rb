require 'csv'

require './lib/statement/csv_transformer'

module FBARPrep
  class Statement
    def initialize(filename:, account:)
      @filename = filename
      @account = account

      raw_data = CSV.read(filename, headers: true, encoding: "bom|utf-8")

      @data = CsvTransformer.new(bank_account, raw_data, filename:).transform
    end

    attr_reader :filename, :account, :data

    alias transactions data
    alias bank_account account

    def has_transactions?
      !transactions.empty?
    end

    def first_transaction_date
      transactions.first.date
    end

    Transaction = Struct.new(:account, :date, :details, :type, :amount, :balance, keyword_init: true)
  end
end
