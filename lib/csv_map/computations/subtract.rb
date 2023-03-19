require_relative './base'

module FBARPrep
  class CSVMap
    module Computations
      class Subtract < Base
        class InvalidSubtractParameterError < StandardError; end

        class << self
          def mapping_key
            'subtract'
          end
        end

        def perform
          raise InvalidSubtractParameterError.new(operands) unless operands.size == 2

          value(operands[0]) - value(operands[1])
        end

        private

        def transform(val)
          Float(val)
        end
      end
    end
  end
end

