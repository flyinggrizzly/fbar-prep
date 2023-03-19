require_relative './base'

module FBARPrep
  class CSVMap
    module Computations
      class FirstNotNull < Base
        class NoPossibleValuesError < StandardError; end

        class << self
          def mapping_key
            'first_not_null'
          end
        end

        def perform
          values = operands.map {|operand| safe_value(operand)}.compact

          raise NoPossibleValuesError.new(operands) if values.empty?

          values.first
        end

        private

        # Some computations may be impossible for some rows (e.g. Multiply will attempt to coerce nil to a Float), and
        # we want to allow execution to continue.
        def safe_value(v)
          value(v)
        rescue
          return nil
        end
      end
    end
  end
end

