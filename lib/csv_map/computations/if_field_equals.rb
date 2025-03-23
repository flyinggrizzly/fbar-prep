require_relative './base'

module FBARPrep
  class CSVMap
    module Computations
      class IfFieldEquals < Base
        class IfFieldEqualsError < StandardError; end

        class << self
          def mapping_key
            'if_field_equals'
          end
        end

        def perform
          raise IfFieldEqualsError.new(operands) unless operands.size == 2

          tested_field_value = value(operands[0], allow_nil_in_field: true)
          test_value = operands[1] # note the literal

          tested_field_value == test_value
        end
      end
    end
  end
end
