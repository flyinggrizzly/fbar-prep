require './spec/spec_helper'

require './lib/statement'
require './lib/csv_map/computations'

RSpec.describe FBARPrep::CSVMap::Computations::Prefix do
  let(:operands) {[
    'Detail',
    'detail='
  ]}
  let(:csv_row) {{
    'Detail' => 'Some garbage',
    'In' => '100.01'
  }}
  let(:transactions) { [FBARPrep::Statement::Transaction.new(balance: 1.00)] }

  it 'prefixes the first value with the second' do
    computation = FBARPrep::CSVMap::Computations.for('prefix', operands, csv_row, transactions)

    expect(computation.perform).to eq('detail=Some garbage')
  end

  context 'with computed values' do
    let(:operands) {[
      {
        'compute' => {
          'add' => [
            '$CONSTANTS.NUMBER[1]',
            '$CONSTANTS.NUMBER[2]',
          ]
        }
      },
      'look I can do addition='
    ]}

    it 'prefixes the first value with the second' do
      computation = FBARPrep::CSVMap::Computations.for('prefix', operands, csv_row, transactions)

      expect(computation.perform).to eq('look I can do addition=3.0')
    end
  end
end

