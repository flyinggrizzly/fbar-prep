require 'active_support/all'

require_relative './csv_map/special_value_evaluators'
require_relative './csv_map/factory'
require_relative './csv_map/validator'
require_relative './csv_map/value_mappers'
require_relative './csv_map/ordering'
require_relative './statement'

module FBARPrep
  class CSVMap
    MappedRow = Struct.new(:date, :amount, :balance, :details, :type, keyword_init: true)

    class << self
      def for(account)
        Factory.build(account)
      end
    end

    REQUIRED_MAPPINGS = [
      {
        "field" => "date",
        "subfields" => [
          "field",
          "format"
        ]
      },
      "balance"
    ].freeze

    OPTIONAL_MAPPINGS = [
      "type",
      "in",
      "out",
      "details",
    ].freeze

    def initialize(map)
      @map = map.deep_stringify_keys
      validate!
    end

    attr_reader :map

    def validate_statement_data!(_data)
      # TODO: add this to the mapping defs
      true
    end

    def map_row(csv_row, transactions)
      row = MappedRow.new

      mappings = map.fetch('mappings')

      mappings.each do |our_field, foreign_field_data|
        value = ValueMappers.map(our_field, foreign_field_data, csv_row, transactions)

        row.public_send("#{our_field}=", transform_value(our_field, value))
      end

      row
    end

    def ordered_rows(rows)
      first_csv_row_is = map.fetch('first_csv_row_is')

      if  Ordering.reverse?(first_csv_row_is)
        rows.reverse
      elsif Ordering.static?(first_csv_row_is)
        rows
      else
        raise 'wtf'
      end
    end

    private

    def validate!
      Validator.new(REQUIRED_MAPPINGS, OPTIONAL_MAPPINGS, map).validate!
    end

    def transform_value(our_field, value)
      return float_or_nil(value) if ['balance', 'amount'].include?(our_field)

      value
    end

    def float_or_nil(value)
      return nil if value.nil?

      value.to_f
    end
  end
end
