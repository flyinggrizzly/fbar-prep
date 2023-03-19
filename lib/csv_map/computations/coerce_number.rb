require_relative './base'

module FBARPrep
  class CSVMap
    module Computations
      class CoerceNumber < Base
        class InvalidCoerceNumberParameterError < StandardError; end

        class << self
          def mapping_key
            'coerce_number'
          end
        end

        def perform
          raise InvalidCoerceNumberParameterError.new(operands) unless operands.size == 1

          operand = value(operands.first)

          return 0.00 if operand.nil?

          Float(operand)
        end
      end
    end
  end
end
