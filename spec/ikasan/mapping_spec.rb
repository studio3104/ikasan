require 'spec_helper'
require 'ikasan/mapping'
require 'tempfile'

describe 'Mapping' do
  let(:file) { File.join(File.dirname(__FILE__), '../../config/mapping.sample.tsv') }
  let(:empty_file) { Tempfile.new('mapping.empty.tsv') }
  let(:logger) { Logger.new(Tempfile.new('mapping_spec.rb.log')) }
  let(:mapping) { Ikasan::Mapping.new(file, logger) }
  let(:empty_mapping) { Ikasan::Mapping.new(empty_file, logger) }

  it '#empty?' do
    expect(mapping.empty?).to be_a FalseClass
    expect(empty_mapping.empty?).to be_a TrueClass
  end

  it '#keys' do
    expect(mapping.keys).to eq %w[ #ikachan #studio3104 ]
    expect(empty_mapping.keys).to eq []
  end

  it '#values' do
    expect(mapping.values).to eq [%w[ ikasan #ikasan ], %w[ studio3104 ]]
    expect(empty_mapping.values).to eq []
  end
end
