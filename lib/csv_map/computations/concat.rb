require 'active_support/all'

require_relative './base'

module FBARPrep
  class CSVMap
    module Computations
      class Concat < Base
        class << self
          def mapping_key
            'concat'
          end
        end

        def perform
          delimiter, values = delimiter_and_values

          values.map {|v| value(v)}.reject(&:blank?).join(delimiter)
        end

        private

        def delimiter_and_values
          first_operand = operands.first

          if first_operand.is_a?(Hash) && first_operand.keys == ['delimiter']
            [first_operand.fetch('delimiter'), operands.slice(1, operands.size)]
          else
            [' | ', operands]
          end
        end
      end
    end
  end
end
