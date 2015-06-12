require 'spec_helper'
require 'ikasan/config'

describe 'Config' do
  let(:file) { File.join(File.dirname(__FILE__), '../../config/config.sample.toml') }
  let(:conf) { Ikasan::Config.new(file) }

  describe '#symbolize_recursive' do
    it 'simple' do
      hash = { 'key' => 'value' }
      expect(
        conf.send(:symbolize_recursive, hash)
      ).to eq({ key: 'value' })
    end

    it 'value is simple array' do
      hash = { 'key' => %w[ value0 value1 value2 ] }
      expect(
        conf.send(:symbolize_recursive, hash)
      ).to eq({ key: %w[ value0 value1 value2 ] })
    end

    it 'value is simple hash' do
      hash = { 'key' => { 'value_key' => 'value' } }
      expect(
        conf.send(:symbolize_recursive, hash)
      ).to eq({ key: { value_key: 'value' } })
    end

    it 'value is array include hash and string' do
      hash = { 'key' => [ { 'value_key0' => 'value0' }, { 'value_key1' => 'value1' }, 'value2' ] }
      expect(
        conf.send(:symbolize_recursive, hash)
      ).to eq({
        key: [
          { value_key0: 'value0' },
          { value_key1: 'value1' },
          'value2',
        ]
      })
    end
  end

  describe 'hipchat' do
    it 'default_nickname' do
      expect(conf[:hipchat][:default_nickname]).to be_a String
    end
    it 'nickname' do
      expect(conf[:hipchat][:nickname]).to be_a String
    end
    it 'api_tokens' do
      expect(conf[:hipchat][:api_tokens]).to be_a Array
    end
    it 'server_url' do
      expect(conf[:hipchat][:server_url]).to be_a String
    end
  end

  describe 'admin' do
    it 'imkayac' do
      expect(conf[:admin][:imkayac]).to be_a Array
    end
  end
end
