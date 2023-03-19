require_relative './special_value_evaluators/transactions/previous_balance'
require_relative './special_value_evaluators/constants/number'
require_relative './special_value_evaluators/constants/null'

module FBARPrep
  class CSVMap
    module SpecialValueEvaluators
      class UnknownSpecialValueError < StandardError; end
      class << self
        def for(special_value_name, csv_row, transactions)
          id_data = Identifier.new(special_value_name).identify

          raise UnknownSpecialValueError(special_value_name) if id_data.nil?

          namespace = id_data.fetch('namespace')
          value = id_data.fetch('value')
          args = id_data.fetch('args')

          case [namespace, value]
          when ['TRANSACTIONS', 'PREVIOUS_BALANCE']
            Transactions::PreviousBalance.new(csv_row, transactions)
          when ['CONSTANTS', 'NULL']
            Constants::Null.new
          when ['CONSTANTS', 'NUMBER']
            Constants::Number.new(args)
          when ['CONSTANTS', 'ZERO']
            Constants::Number.new(0.00)
          when ['CONSTANTS', 'ONE']
            Constants::Number.new(1.00)
          when ['CONSTANTS', 'MINUS_ONE']
            Constants::Number.new(-1.00)
          else
            raise UnknownSpecialValueError(special_value_name)
          end
        end

        def special_value?(special_value_name)
          !Identifier.new(special_value_name).match_data.nil?
        end
      end

      Identifier = Struct.new(:special_value_name) do
        def identify
          match_data&.named_captures
        end

        def match_data
          return unless special_value_name.is_a?(String)

          # TODO: add more namespaces
          namespaces = [
            'TRANSACTIONS',
            'CONSTANTS'
          ]
          svn_re = namespaces.join('|')

          re = /^\$(?<namespace>#{svn_re})\.(?<value>[A-Z_]+)(?:\[(?<args>.+)\])?$/

          special_value_name.match(re)
        end
      end
    end
  end
end
