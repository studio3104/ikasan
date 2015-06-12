require 'spec_helper'

describe 'Ikasan App' do
  let(:valid_colors) { %w[ yellow red green purple gray random ] }
  let(:invalid_colors) { %w[ blue white black ] }
  let(:valid_message_formats) { %w[ html text ] }
  let(:invalid_message_formats) { %w[ htm txt ] }
  let(:invalid_length_message) { SecureRandom.hex(5001) }

  describe 'GET /' do
    it 'index' do
      get '/'
      expect(last_response).to be_ok
    end
  end

  describe 'POST /notice' do
    it 'specify only required' do
      post '/notice', {
        channel: 'channel',
        message: 'message',
      }
      expect(last_response).to be_ok
      expect(JSON.parse(last_response.body)['error']).to eq 0
    end

    it 'not specify only required' do
      post '/notice', {
        channel: 'channel',
      }
      expect(last_response).to_not be_ok
      expect(last_response.body).to eq('["message: invalid length range"]')
    end

    it 'specify all of valid request parameters' do
      post '/notice', {
        nickname: 'moznion',
        channel: 'channel',
        message: 'message',
        color: valid_colors.sample,
        message_format: valid_message_formats.sample
      }
      expect(last_response).to be_ok
      expect(JSON.parse(last_response.body)['error']).to eq 0
    end

    it 'specify invalid color' do
      post '/notice', {
        channel: 'channel',
        message: 'message',
        color: invalid_colors.sample,
      }
      expect(last_response).to_not be_ok
      expect(last_response.body).to eq('["color: invalid value"]')
    end

    it 'specify invalid message_format' do
      post '/notice', {
        channel: 'channel',
        message: 'message',
        message_format: invalid_message_formats.sample
      }
      expect(last_response).to_not be_ok
      expect(last_response.body).to eq('["message_format: invalid value"]')
    end

    it 'specify invalid length message' do
      post '/notice', {
        channel: 'channel',
        message: invalid_length_message,
      }
      expect(last_response).to_not be_ok
      expect(last_response.body).to eq('["message: invalid length range"]')
    end
  end

  describe 'POST /privmsg' do
    it 'specify only required' do
      post '/privmsg', {
        channel: 'channel',
        message: 'message',
      }
      expect(last_response).to be_ok
      expect(JSON.parse(last_response.body)['error']).to eq 0
    end

    it 'not specify only required' do
      post '/privmsg', {
        channel: 'channel',
      }
      expect(last_response).to_not be_ok
      expect(last_response.body).to eq('["message: invalid length range"]')
    end

    it 'specify all of valid request parameters' do
      post '/privmsg', {
        nickname: 'moznion',
        channel: 'channel',
        message: 'message',
        color: valid_colors.sample,
        message_format: valid_message_formats.sample
      }
      expect(last_response).to be_ok
      expect(JSON.parse(last_response.body)['error']).to eq 0
    end

    it 'specify invalid color' do
      post '/privmsg', {
        channel: 'channel',
        message: 'message',
        color: invalid_colors.sample,
      }
      expect(last_response).to_not be_ok
      expect(last_response.body).to eq('["color: invalid value"]')
    end

    it 'specify invalid message_format' do
      post '/privmsg', {
        channel: 'channel',
        message: 'message',
        message_format: invalid_message_formats.sample
      }
      expect(last_response).to_not be_ok
      expect(last_response.body).to eq('["message_format: invalid value"]')
    end

    it 'specify invalid length message' do
      post '/privmsg', {
        channel: 'channel',
        message: invalid_length_message,
      }
      expect(last_response).to_not be_ok
      expect(last_response.body).to eq('["message: invalid length range"]')
    end
  end
end
