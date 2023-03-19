require_relative './base'

module FBARPrep
  class CSVMap
    module Computations
      class Prefix < Base
        class InvalidPrefixParameterError < StandardError; end

        class << self
          def mapping_key
            'prefix'
          end
        end

        def perform
          raise InvalidPrefixParameterError.new(operands) unless operands.size == 2

          to_be_prefixed = value(operands[0])
          prefix = operands[1] # Note the literal

          "#{prefix}#{to_be_prefixed}"
        end

        private

        def transform(val)
          val.to_s
        end
      end
    end
  end
end
