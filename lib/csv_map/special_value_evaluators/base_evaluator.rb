module FBARPrep
  class CSVMap
    module SpecialValueEvaluators
      class BaseEvaluator
        def initialize(csv_row, transactions)
          @csv_row = csv_row
          @transactions = transactions
        end

        attr_reader :csv_row, :transactions

        def evaluate!
          raise NotImplementedError
        end
      end
    end
  end
end
