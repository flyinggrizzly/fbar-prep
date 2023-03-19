require_relative '../base_evaluator'

module FBARPrep
  class CSVMap
    module SpecialValueEvaluators
      module Transactions
        class PreviousBalance < BaseEvaluator
          def evaluate
            transactions.last&.balance || 0.00
          end
        end
      end
    end
  end
end
