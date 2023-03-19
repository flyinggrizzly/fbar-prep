require './spec/spec_helper'

require './lib/csv_map/computations'

RSpec.describe FBARPrep::CSVMap::Computations::CoerceNumber do
  it 'coerces safely coercable number strings' do
    coerced = FBARPrep::CSVMap::Computations.for(
      'coerce_number',
      [ 'Number' ],
      { 'Number' => '1.1' },
      []
    ).perform

    expect(coerced).to eq(1.1)
  end

  it 'coerces nil to 0' do
    coerced = FBARPrep::CSVMap::Computations.for(
      'coerce_number',
      [ 'Number' ],
      { 'Number' => nil },
      []
    ).perform

    expect(coerced).to eq(0.00)
  end
end
