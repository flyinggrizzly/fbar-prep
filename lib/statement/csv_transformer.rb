require './lib/statement'
require './lib/csv_map'
require './lib/currency'

module FBARPrep
  class Statement
    class CsvTransformer
      def initialize(account, csv)
        @account = account
        @csv = csv
        @map = FBARPrep::CSVMap.for(account)
      end

      attr_reader :account, :csv, :map

      def transform
        transactions = []
        rows.each {|row| add_transaction(row, transactions)}

        transactions
      end

      private

      def add_transaction(row, transactions)
        remapped_data = map.map_row(row, transactions)

        transactions.push(Statement::Transaction.new(
          account:,
          date: remapped_data.date,
          amount: money(remapped_data.amount, remapped_data.date),
          balance: money(remapped_data.balance, remapped_data.date),
          details: remapped_data.details,
          type: remapped_data.type
        ))
      end

      def money(float, date)
        Currency.from_float_on(float, account.currency, date.year)
      end

      def rows
        map.ordered_rows(csv.entries)
      end
    end
  end
end
