require 'logger'
require 'focuslight-validator'
require 'ikasan/sender'
require 'ikasan/config'
require 'ikasan/mapping'

module Ikasan
  module Helper
    def validate(params)
      Focuslight::Validator.validate(
        params,
        channel: {
          rule: rule(:not_blank),
        },
        message: {
          # Valid length range: 1 - 10000 (ref: https://www.hipchat.com/docs/apiv2/method/send_room_notification)
          rule: rule(:lambda, ->(m) { m && (1..10000).include?(m.strip.length) }, 'invalid length range', :strip),
        },
        color: {
          default: 'yellow',
          rule: rule(:choice, %w[ yellow red green purple gray random ]),
        },
        message_format: {
          default: 'text',
          rule: rule(:choice, %w[ html text ]),
        },
        notify: {
          rule: rule(:bool),
        },
      )
    end

    def room_mapping_of
      file_path = settings.root + '/config/mapping.tsv'
      file = File.exist?(file_path) ? file_path : settings.root + '/config/mapping.sample.tsv'
      @@room_mapping_of ||= Mapping.new(file, logger)
    end

    # チャンネルに対応するルームが登録されていれば、HipChatのそのルームに対して通知を行う
    # 登録がなければ params[:channel] をルーム名とみなしてそのままHipChatに投げる
    def enqueue_message(params)
      rooms = room_mapping_of[params[:channel]] || [params[:channel]]
      message = remove_mirc_code(params[:message])
      color = params[:color]
      message_format = params[:message_format]
      fails = []

      rooms.each do |room|
        begin
          sender.enqueue(
            room: room,
            message: message,
            color: color,
            message_format: message_format,
            notify: params[:notify],
          )
        rescue
          fails << room
        end
      end

      # response body用のハッシュ
      # メッセージが実際に送れたかどうかはわからないので、enqueueに成功してたらsuccessとする
      result = { error: 0, type: params[:notify] ? 'privmsg' : 'notice', message: message, success: { rooms: rooms } }
      if !fails.empty?
        result.merge(error: 1, success: { rooms: rooms - fails }, fail: { rooms: fails })
      end
      result
    end

    private

    def rule(*args)
      Focuslight::Validator.rule(*args)
    end

    def logger
      @@logger ||= Logger.new("#{settings.root}/log/#{settings.environment}.log", 10)
    end

    def conf
      file_path = settings.root + '/config/config.toml'
      file = File.exist?(file_path) ? file_path : settings.root + '/config/config.sample.toml'
      @@config ||= Config.new(file)
    end

    def sender
      @@sender ||= Sender.new(conf, logger)
    end

    MIRC_ESCAPE_CODE_REGEXP = /[\x02\x03\x12\x15\x0B\x0F]/
    MIRC_START_SEQUENCE_REGEXP = /#{MIRC_ESCAPE_CODE_REGEXP}[0-9]{1,2}(?:,[0-9]{1,2})?/
    def remove_mirc_code(input)
      input.gsub(MIRC_START_SEQUENCE_REGEXP, '').gsub(MIRC_ESCAPE_CODE_REGEXP, '')
    end
  end
end
