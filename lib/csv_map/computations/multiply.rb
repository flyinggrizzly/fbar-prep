require_relative './base'

module FBARPrep
  class CSVMap
    module Computations
      class Multiply < Base
        class << self
          def mapping_key
            'multiply'
          end
        end

        def perform
          operands.map {|operand| value(operand)}.inject(1, :*)
        end

        private

        def transform(val)
          Float(val)
        end
      end
    end
  end
end

