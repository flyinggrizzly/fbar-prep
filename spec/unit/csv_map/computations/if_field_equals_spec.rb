require './spec/spec_helper'

require './lib/statement'
require './lib/csv_map/computations'

RSpec.describe FBARPrep::CSVMap::Computations::IfFieldEquals do
  let(:operands) {[
    'Category',
    'Food'
  ]}
  let(:csv_row) {{
    'Category' => 'Food',
    'Amount' => '10.00'
  }}
  let(:transactions) { [] }

  it 'returns true when the field value equals the test value' do
    computation = FBARPrep::CSVMap::Computations.for('if_field_equals', operands, csv_row, transactions)
    
    expect(computation.perform).to eq(true)
  end

  context 'when the field value does not equal the test value' do
    let(:csv_row) {{
      'Category' => 'Entertainment',
      'Amount' => '20.00'
    }}

    it 'returns false' do
      computation = FBARPrep::CSVMap::Computations.for('if_field_equals', operands, csv_row, transactions)
      
      expect(computation.perform).to eq(false)
    end
  end

  context 'when the field is missing' do
    let(:csv_row) {{
      'Amount' => '10.00'
    }}

    it 'returns false because nil != test_value' do
      computation = FBARPrep::CSVMap::Computations.for('if_field_equals', operands, csv_row, transactions)
      
      expect(computation.perform).to eq(false)
    end
  end

  context 'with invalid operands' do
    let(:operands) {[
      'Category'
    ]}

    it 'raises an error when operands size is not 2' do
      computation = FBARPrep::CSVMap::Computations.for('if_field_equals', operands, csv_row, transactions)
      
      expect { computation.perform }.to raise_error(FBARPrep::CSVMap::Computations::IfFieldEquals::IfFieldEqualsError)
    end
  end
end