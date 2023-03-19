require './spec/spec_helper'

require './lib/csv_map/computations'
require './lib/statement'

RSpec.describe 'Composing computations' do
  # Build full mapping entry for sanity and to ground this in a real-world requirement: CSV defines Money In and
  # Money Out both as positive Float columns, and provides no Balance column, and we need to determine what the balance
  # is by arithmetic
  let(:mapping_entry) {
    {
      'balance' => {
        'compute' => {
          'add' => [
            '$TRANSACTIONS.PREVIOUS_BALANCE',
            {
              'compute' => {
                'first_not_null' => [
                  'Money In',
                  {
                    'compute' => {
                      'multiply' => [
                        'Money Out',
                        '$CONSTANTS.MINUS_ONE'
                      ]
                    }
                  },
                  '$CONSTANTS.ZERO'
                ]
              }
            }
          ]
        }
      }
    }
  }
  let(:initial_operation) { 'add' }

  # Now grab the part we care about
  let(:operands) { mapping_entry['balance']['compute'][initial_operation] }

  let(:transactions) { [FBARPrep::Statement::Transaction.new(balance: 10.00)] }

  it 'is possible to compose computations' do
    money_in_present_computation = FBARPrep::CSVMap::Computations.for(
      'add',
      operands,
      {
        'Money In' => '5.01'
      },
      transactions
    )

    expect(money_in_present_computation.perform).to eq(15.01)

    money_out_computation = FBARPrep::CSVMap::Computations.for(
      'add',
      operands,
      {
        'Money Out' => '10.01'
      },
      transactions
    )

    expect(money_out_computation.perform.round(2)).to eq(-0.01)

    no_row_data_computation = FBARPrep::CSVMap::Computations.for(
      'add',
      operands,
      {},
      transactions
    )

    expect(no_row_data_computation.perform).to eq(10.00)
  end
end

