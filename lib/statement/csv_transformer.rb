require './lib/statement'
require './lib/csv_map'

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
          amount: remapped_data.amount,
          balance: remapped_data.balance,
          details: remapped_data.details,
          type: remapped_data.type
        ))
      end

      def rows
        map.ordered_rows(csv.entries)
      end
    end
  end
end
