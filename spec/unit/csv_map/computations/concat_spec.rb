require './spec/spec_helper'

require './lib/csv_map/computations'

RSpec.describe FBARPrep::CSVMap::Computations::Concat do
  let(:csv_row) {
    {
      'Detail' => 'Some deets',
      'Note' => 'A note'
    }
  }
  let(:transactions) {[]}

  let(:computation) {
    FBARPrep::CSVMap::Computations.for(
      'concat',
      operands,
      csv_row,
      transactions
    )
  }

  context 'with default delimiter' do
    let(:operands) {
      [
        'Detail',
        'Note'
      ]
    }

    it 'concatenates the values' do
      expect(computation.perform).to eq("Some deets | A note")
    end
  end

  context 'with a parameter delimiter' do
    let(:operands) {[
      { 'delimiter' => '; ' },
      'Detail',
      'Note'
    ]}

    it 'concatenates the values' do
      expect(computation.perform).to eq("Some deets; A note")
    end
  end
end

