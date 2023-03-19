require 'date'

require_relative './computations'

module FBARPrep
  class CSVMap
    module ValueMappers
      class UnknownMapperError < StandardError; end

      class << self
        def map(our_field, foreign_field_data, csv_row, transactions)
          if foreign_field_data.is_a?(String)
            if SpecialValueEvaluators.special_value?(foreign_field_data)
              SpecialValueEvaluators.for(foreign_field_data, csv_row, transactions).evaluate
            else
              SimpleMapper.map!(csv_row, foreign_field_data)
            end
          elsif our_field == 'date'
            # Date can be handled by simple mapper or the Complex mapper, if the format is ambiguous. The SimpleMapper
            # should take priority.
            #
            # Currently no other fields are supported by the ComplexFieldDefinitionMapper
            ComplexFieldDefinitionMapper.new(our_field, csv_row, foreign_field_data).map!
          elsif foreign_field_data.keys == ['compute']
            ComputedMapper.new(csv_row, foreign_field_data.fetch('compute'), transactions).map!
          else
            raise UnknownMapperError.new(foreign_field_data, our_field)
          end
        end
      end

      module SimpleMapper
        extend self

        def map!(csv_row, key)
          csv_row.fetch(key)
        end
      end

      class ComputedMapper
        def initialize(csv_row, computation_def, transactions)
          @csv_row = csv_row
          @computation_def = computation_def
          @transactions = transactions
        end

        attr_reader :csv_row, :computation_def, :transactions

        def map!
          operations = computation_def.keys

          raise 'n > 1 operations not implemented' unless operations.size == 1

          operation = operations.first

          operands = computation_def.fetch(operation)

          Computations.for(operation, operands, csv_row, transactions).perform
        end
      end

      class ComplexFieldDefinitionMapper
        def initialize(our_field, csv_row, mapping)
          raise 'complex fields only supported for date' unless our_field == 'date'

          @csv_row = csv_row
          @mapping = mapping
        end

        attr_reader :mapping, :csv_row

        def map!
          map_date!
        end

        private

        def map_date!
          # see https://ruby-doc.org/stdlib-2.4.1/libdoc/date/rdoc/Date.html#method-i-strftime for formatting

          raw_value = csv_row.fetch(mapping.fetch('field'))

          Date.strptime(raw_value, mapping.fetch('format'))
        end
      end
    end
  end
end

