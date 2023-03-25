module FBARPrep
  class CSVMap
    class OrderedRows
      class InvalidOrderingError < StandardError; end

      NEW = [
        'new',
        'newest'
      ].freeze

      OLD = [
        'old',
        'oldest'
      ].freeze

      ALL = (OLD + NEW).freeze

      class << self
        def valid?(value)
          ALL.include?(value)
        end
      end

      def initialize(first_csv_row_is, rows)
        @first_csv_row_is = first_csv_row_is
        @raw_rows = rows
      end

      attr_reader :first_csv_row_is, :raw_rows

      def rows
        if reverse?
          raw_rows.reverse
        elsif static?
          raw_rows
        else
          raise InvalidOrderingError.new(first_csv_row_is)
        end
      end

      def reverse?
        NEW.include?(first_csv_row_is)
      end

      def static?
        OLD.include?(first_csv_row_is)
      end

      def valid?
        reverse?(first_csv_row_is) || static?(first_csv_row_is)
      end
    end
  end
end

