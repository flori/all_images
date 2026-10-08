require 'spec_helper'

RSpec.describe AllImages::App do
  it 'can be instantiated' do
    expect(described_class.new([])).to be_a described_class
  end

  xit 'can fail' do
    expect(true).to eq false
  end

  it 'has columns and lines' do
    skip 'not in all images' if ENV['ALL_IMAGES'].to_i == 0
    expect(ENV.values_at('COLUMNS', 'LINES')).to eq %w[ 80 25 ]
  end

  it 'has term' do
    skip 'not in all images' if ENV['ALL_IMAGES'].to_i == 0
    expect(ENV['TERM']).to eq 'xterm'
  end
end
