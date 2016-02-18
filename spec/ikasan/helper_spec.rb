require 'spec_helper'
require 'ikasan/helper'

describe 'Helper' do
  let(:logger_) { Logger.new(Tempfile.new('mapping_spec.rb.log')) }
  let(:mapping_file) { File.join(File.dirname(__FILE__), '../../config/mapping.sample.tsv') }
  let(:mapping_) { Ikasan::Mapping.new(mapping_file, logger_) }
  let(:config_file) { File.join(File.dirname(__FILE__), '../../config/config.sample.toml') }
  let(:conf_) { Ikasan::Config.new(config_file) }

  let(:valid_request_parameters) {
  }

  include Ikasan::Helper

  def logger() logger_ end
  def conf() conf_ end
  def room_mapping_of() mapping_ end

  describe 'validation' do
    let(:valid_colors) { %w[ yellow red green purple gray random ] }
    let(:invalid_colors) { %w[ blue white black ] }
    let(:valid_message_formats) { %w[ html text ] }
    let(:invalid_message_formats) { %w[ htm txt ] }
    let(:invalid_length_message) { SecureRandom.hex(5001) }

    it 'specify only required' do
      result = validate(
        channel: 'channel',
        message: 'message',
        notify: '0',
      )
      expect(result.has_error?).to be_a FalseClass
    end

    it 'not specify only required' do
      result = validate(
        channel: 'channel',
        notify: '0',
      )
      expect(result.has_error?).to be_a TrueClass
      expect(result.errors).to eq({ message: 'message: invalid length range' })
    end

    it 'specify all of valid request parameters' do
      result = validate(
        channel: 'channel',
        message: 'message',
        color: valid_colors.sample,
        message_format: valid_message_formats.sample,
        notify: '0',
      )
      expect(result.has_error?).to be_a FalseClass
    end

    it 'specify invalid color' do
      result = validate(
        channel: 'channel',
        message: 'message',
        color: invalid_colors.sample,
        notify: '0',
      )
      expect(result.has_error?).to be_a TrueClass
      expect(result.errors).to eq({ color: 'color: invalid value' })
    end

    it 'specify invalid message_format' do
      result = validate(
        channel: 'channel',
        message: 'message',
        message_format: invalid_message_formats.sample,
        notify: '0',
      )
      expect(result.has_error?).to be_a TrueClass
      expect(result.errors).to eq({ message_format: 'message_format: invalid value' })
    end

    it 'specify invalid length message' do
      result = validate(
        channel: 'channel',
        message: invalid_length_message,
        message_format: valid_message_formats.sample,
        notify: '0',
      )
      expect(result.has_error?).to be_a TrueClass
      expect(result.errors).to eq({ message: 'message: invalid length range' })
    end

    it 'specify invalid nickname' do
      ['@moznion', '<studio3104', 'fuba>', 'h@ge'].each do |nickname|  # invalid characters: '@', '<', '>'
        result = validate(
          nickname: nickname,
          channel: 'channel',
          message: 'message',
          color: valid_colors.sample,
          message_format: valid_message_formats.sample,
          notify: '0',
        )
        expect(result.has_error?).to be_a TrueClass
        expect(result.errors).to eq({ nickname: %q[nickname: '@', '<' and '>' aren't supported] })
      end
    end
  end

  describe 'enqueue' do
    it 'valid parameters' do
      expect(enqueue_message(
        {
          channel: 'channel',
          message: 'message',
          color: 'random',
          message: 'format',
          notify: false,
        }
      )[:error]).to eq 0
    end
  end

  describe 'trim mirc escape sequence code' do
    it 'examples' do
      {
        "\x035,12colored text and background\x03" => 'colored text and background',
        "\x035colored text\x03" => 'colored text',
        "\x033colored text \x035,2more colored text and background\x03" => 'colored text more colored text and background',
        "\x033,5colored text and background \x038other colored text but same background\x03" => 'colored text and background other colored text but same background',
        "\x033,5colored text and background \x038,7other colored text and different background\x03" => 'colored text and background other colored text and different background',
      }.each do |problem, correct|
        expect(remove_mirc_code(problem)).to eq correct
      end
    end

    it 'ふつうのケースをパスする' do
      expect(remove_mirc_code("aaa")).to eq 'aaa'
    end

    it '日本語をパスする' do
      expect(remove_mirc_code("日本語")).to eq '日本語'
    end

    it 'カラーコードが除去される' do
      expect(remove_mirc_code("a\x03b")).to eq 'ab'
      expect(remove_mirc_code("a\x035b")).to eq 'ab'
    end

    it '背景色指定のカラーコードが除去される [,M]' do
      expect(remove_mirc_code("a\x035,4b")).to eq 'ab'
    end

    it 'mircのいろんな制御文字が除去される' do
      expect(
        remove_mirc_code("a\x025b\x034,2c\x153d\x122e\x0B1f\x0Fz\ta")
      ).to eq "abcdefz\ta"
    end

    it '関係ない制御文字が除去されない' do
      expect(
        remove_mirc_code("a\r\nb\tc")
      ).to eq "a\r\nb\tc"
    end
  end
end
