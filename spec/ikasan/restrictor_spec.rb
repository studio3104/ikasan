require 'spec_helper'
require 'ikasan/config'
require 'ikasan/restrictor'

describe Ikasan::Restrictor do
  let(:config_file) { File.join(File.dirname(__FILE__), '../../config/config.sample.toml') }
  let(:conf) { Ikasan::Config.new(config_file) }
  let(:restrictor) { Ikasan::Restrictor.new(conf[:hipchat][:restrict][:message_count], conf[:hipchat][:restrict][:duration]) }

  it '#increase_sent_count' do
    restrictor.increase_sent_count('test room name')
  end

  it '#sendable?' do
    expect(restrictor.sendable?('test room name')).to be_truthy
  end
end
