require_relative './base'

module FBARPrep
  class CSVMap
    module Computations
      class Add < Base
        class << self
          def mapping_key
            'add'
          end
        end

        def perform
          operands.map {|operand| value(operand)}.sum(0)
        end

        private

        def transform(val)
          Float(val)
        end
      end
    end
  end
end
