require './spec/spec_helper'

require './lib/csv_map'
require './lib/statement'

RSpec.describe FBARPrep::CSVMap do
  let(:first_row) { "oldest" }
  let(:minimal_mapping) {
    {
      mappings: {
        date: {
          field: 'Date',
          format: '%d/%m/%Y'
        },
        amount: 'Amount',
        balance: 'Balance',
        details: 'Details',
        type: 'Type'
      },
      first_csv_row_is: first_row
    }
  }

  it 'initializes with a hash' do
    expect {
      described_class.new(minimal_mapping)
    }.not_to raise_error
  end

  describe '#map_row' do
    context 'with a computational map' do
      context 'with an `add` computation' do
        let(:computational_mapping) {
          {
            mappings: {
              date: {
                field: 'Date',
                format: '%d/%m/%Y'
              },
              amount: {
                compute: {
                  first_not_null: [
                    'Money In',
                    {
                      compute: {
                        multiply: [
                          '$CONSTANTS.MINUS_ONE',
                          'Money Out'
                        ]
                      }
                    },
                    '$CONSTANTS.ZERO'
                  ]
                }
              },
              balance: {
                compute: {
                  add: [
                    '$TRANSACTIONS.PREVIOUS_BALANCE',
                    'Amount'
                  ]
                }
              },
              details: 'Details',
              type: 'Type'
            },
            first_csv_row_is: first_row
          }
        }

        it 'performs the computation' do
          mapper = described_class.new(computational_mapping)
          row = {
            'Date' =>  '31/12/2020',
            'Money In' =>  '100',
            'Money Out' =>  nil,
            'Amount' => '100',
            'Details' =>  'Some transaction info',
            'Type' =>  'Faster Inward Payment'
          }
          prior_transactions = [
            FBARPrep::Statement::Transaction.new(
              balance: 231.14,
              amount: -45.10,
              type: 'BACS',
              details: 'stuff'
            )
          ]

          expect(mapper.map_row(row, prior_transactions).balance).to eq(331.14)
        end
      end
    end

    context 'with a simple map' do
      it 'maps from provided field name into the struct field' do
        mapper = described_class.new(minimal_mapping)

        row = {
          'Date' =>  '31/12/2020',
          'Amount' => '100',
          'Balance' =>  '231.23',
          'Details' =>  'Some transaction info',
          'Type' =>  'Faster Inward Payment'
        }

        expect(mapper.map_row(row, [])).to eq(described_class::MappedRow.new(
          date: Date.new(2020, 12, 31),
          amount: 100.00,
          balance: 231.23,
          details: 'Some transaction info',
          type: 'Faster Inward Payment'
        ))
      end
    end

  end

  describe '#ordered_rows' do
    context 'when rows are ascending in the CSV' do
      it 'does not change row order' do
        map = described_class.new(minimal_mapping)

        expect(map.ordered_rows([1, 2, 3])).to eq([1, 2, 3])
      end
    end

    context 'when rows are ascending in the CSV' do
      let(:first_row) { 'newest' }

      it 'reverses row order' do
        map = described_class.new(minimal_mapping)

        expect(map.ordered_rows([1, 2, 3])).to eq([3, 2, 1])
      end
    end
  end
end

