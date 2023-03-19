require './spec/spec_helper'

require './lib/csv_map/computations/first_not_null'

RSpec.describe FBARPrep::CSVMap::Computations::FirstNotNull do
  let(:simple_operand) { 'Amount' }
  let(:multiplication_operand) {
    {
      'compute' => {
        'multiply' => [
          'Sometimes Float',
          '$CONSTANTS.MINUS_ONE'
        ]
      }
    }
  }
  let(:constant_operand) { '$CONSTANTS.ZERO' }

  let(:operands) {
    [
      simple_operand,
      multiplication_operand,
      constant_operand
    ]
      .compact
  }
  let(:csv_row) {
    {
      'Amount' => '1.01',
      'Sometimes Float' => '10.01'
    }
  }
  let(:transactions) { [] }

  let(:computation) {
    described_class.new(operands, csv_row, transactions)
  }

  it 'returns the first present value' do
    expect(computation.perform).to eq('1.01')
  end

  context 'when a computation should explode' do
    let(:operands) { [multiplication_operand, constant_operand] }
    let(:csv_row) {
      {
        'Amount' => '1.01'
      }
    }

    it 'returns the first present value' do
      expect(computation.perform).to eq(0.00)
    end
  end
end
