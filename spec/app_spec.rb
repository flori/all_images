require 'spec_helper'

RSpec.describe AllImages::App do
  it 'can be instantiated' do
    expect(described_class.new([])).to be_a described_class
  end
end
