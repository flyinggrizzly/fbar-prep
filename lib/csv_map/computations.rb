require_relative './computations/add'
require_relative './computations/concat'
require_relative './computations/coerce_number'
require_relative './computations/first_not_null'
require_relative './computations/multiply'
require_relative './computations/prefix'
require_relative './computations/subtract'


module FBARPrep
  class CSVMap
    module Computations
      class UnsupportedComputationError < StandardError; end

      AVAILABLE_COMPUTATIONS = [
        Add,
        Concat,
        CoerceNumber,
        FirstNotNull,
        Multiply,
        Prefix,
        Subtract,
      ].freeze

      class << self
        def available?(computation_name)
          AVAILABLE_COMPUTATIONS.any? {|computation| computation.implements?(computation_name)}
        end

        def for(computation_name, operands, csv_row, transactions)
          computation = AVAILABLE_COMPUTATIONS.detect {|candidate| candidate.implements?(computation_name)}

          raise UnsupportedComputationError.new(computation_name) if computation.nil?

          computation.new(operands, csv_row, transactions)
        end
      end
    end
  end
end

