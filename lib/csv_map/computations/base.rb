require_relative '../special_value_evaluators'
require './lib/csv_map/computations'

module FBARPrep
  class CSVMap
    module Computations
      class Base
        class ImpossibleComputationValueError < StandardError; end
        class << self
          def mapping_key
            raise NotImplementedError
          end

          def implements?(name)
            mapping_key == name
          end
        end

        def initialize(operands, csv_row, transactions)
          @operands = operands
          @csv_row = csv_row
          @transactions = transactions
        end

        attr_reader :operands, :csv_row, :transactions

        def perform
          raise NotImplementedError
        end

        private

        def value(operand)
          val = if SpecialValueEvaluators.special_value?(operand)
                  SpecialValueEvaluators.for(operand, csv_row, transactions).evaluate
                elsif is_computation?(operand)
                  computation_name, payload = operand.fetch('compute').first
                  
                  Computations.for(computation_name, payload, csv_row, transactions).perform
                elsif operand.is_a?(String)
                  csv_row.fetch(operand)
                else
                  raise ImpossibleComputationValueError.new(operand, self.class.mapping_key)
                end

          transform(val)
        end

        # For string -> number transformations, left to the Computation to decide if necessary
        def transform(val)
          val
        end

        def is_computation?(operand)
          operand.is_a?(Hash) && operand.keys == ['compute']
        end
      end
    end
  end
end
