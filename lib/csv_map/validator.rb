require './lib/csv_map/ordered_rows'

module FBARPrep
  class CSVMap
    class Validator
      class InvalidMappingError < StandardError; end

      def initialize(required_mappings, optional_mappings, map)
        @errors = []
        @required_mappings = required_mappings
        @optional_mappings = optional_mappings
        @map = map
      end

      attr_reader :errors, :required_mappings, :optional_mappings, :map

      def validate!
        validate_mappings!
        validate_csv_order_declaration!

        raise InvalidMappingError.new(errors.join('; ')) unless errors.empty?
      end

      def validate_mappings!
        mappings = map.fetch("mappings")

        required_mappings.each do |rm|
          if rm.is_a?(String)
            errors.push("missing required mapping '#{rm}'") unless mappings.keys.include?(rm)
          else
            validate_complex_required_field_mapping!(rm, mappings)
          end
        end

        optional_mappings.each do |om|
          if om.is_a?(String)
            next
          else
            validate_complex_required_field_mapping!(om, mappings, optional: true)
          end
        end
      end

      def validate_complex_required_field_mapping!(mapping_def, mappings, optional: false)
        required = !optional

        kind = required ? "required" : "optional"

        field_name = mapping_def.fetch("field")
        supplied_mapping = mappings.fetch(field_name, nil)

        errors.push("missing #{kind} mapping #{field_name}") unless supplied_mapping.present? && required

        subfields = mapping_def.fetch("subfields")

        subfields.each do |sf|
          next if supplied_mapping.keys.include?(sf)

          errors.push("missing #{kind} subfield '#{sf}' for #{kind} field '#{field_name}'")
        end
      end

      def validate_csv_order_declaration!
        csv_order = map.fetch('first_csv_row_is')

        errors.push(
          "Invalid 'first_csv_row_is' value '#{csv_order}', must be 'new', 'newest', 'old', or 'oldest'"
        ) unless CSVMap::OrderedRows.valid?(csv_order)
      end
    end
  end
end

