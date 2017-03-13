require 'thread'
require 'hipchat'
require 'im-kayac'
require 'ikasan/queue'
require 'ikasan/restrictor'

module Ikasan
  class Sender
    def initialize(config, logger)
      @config = config
      @logger = logger
      @queue = Queue.new
      @restrictor = Restrictor.new(config[:hipchat][:restrict][:message_count], config[:hipchat][:restrict][:duration])
      @thread = Thread.new(&method(:dequeue))
    end

    def enqueue(q)
      @queue << q
    end

    private

    def dequeue
      all_tokens = conf[:hipchat][:api_tokens].clone
      loop do
        @queue.defrost!
        if @queue.empty?
          sleep 0.1
          next
        end

        bad_tokens = []
        @queue.retrieve.each do |q|
          begin
            if @restrictor.sendable?(q[:room])
              post_message(q)
            else
              next unless conf[:hipchat][:restrict][:stack_burst_message]
              duration = conf[:hipchat][:restrict][:duration]
              if !@queue.frozen_rooms.include?(q[:room])
                message_count = conf[:hipchat][:restrict][:message_count]
                log.warn('limit exceeded') {%Q[sent over than #{message_count} messages during the most recent #{duration} sec to #{q[:room]} room]}
              end
              @queue.freeze(q, duration)
            end
          rescue HipChat::UnknownRoom => e
            # 存在しないルーム名の場合は単にメッセージを捨ててエラーとしない
            log.info('message') { "Unknown room: discard - #{$!.message}" }
          rescue HipChat::UnknownResponseCode, HipChat::Unauthorized => e
            log.warn('api token') { "#{api_token} is dead" }
            bad_tokens << api_token
            if bad_tokens.sort == all_tokens.sort
              # トークンが全部死んだ状態だと、次のトークン次のトークン、、、となるので、
              # いったん5分待って全部のトークンが生き返るのを待つ
              notify_that_all_tokens_are_dead()
              @queue.unshift(q)
              sleep 300
            else
              # この例外時にはAPI制限でPOSTに失敗しているので、トークンを変えてクライアントオブジェクトを再作成してretry
              change_api_token()
              log.warn(e.class) { "#{e.message} (#{q.to_json})" }
              retry
            end
          rescue
            log.error($!.class.to_s) { $!.message }
            log.info('message') { "discard - #{q.to_json}" }

            # キューの内容起因での例外の場合だと例外無限ループしちゃうので@queue.unshift(q)はしない
            # そうじゃない場合は@queue.unshift(q)したほうがいいかも知れないけど...
          end
        end
      end
    end

    # notifyがtrueだとメッセージがポストされたらチャンネル一覧のチャンネル名の色が変わる
    def post_message(q)
      hipchat[q[:room]].send(
        conf[:hipchat][:nickname].sub('{% nickname %}', q[:nickname]),
        q[:message],
        color: q[:color],
        message_format: q[:message_format],
        notify: q[:notify],
      )
      @restrictor.increase_sent_count(q[:room])
      log.info('message') { "#{q[:notify] ? 'privmsg' : 'notice'} - #{q.to_json}" }
    end

    def hipchat
      @hipchat ||= HipChat::Client.new(api_token, api_version: 'v2', server_url: conf[:hipchat][:server_url])
    end

    def change_api_token
      @api_token = nil
      @hipchat = nil
      log.warn('api token') { "switch to #{api_token}" }
    end

    def api_token
      @api_token ||= api_tokens.shift
    end

    def api_tokens
      if !@api_tokens || @api_tokens.empty?
        @api_tokens = conf[:hipchat][:api_tokens].clone
      end
      @api_tokens
    end

    def notify_that_all_tokens_are_dead
      log.error('api token') { 'all are dead' }
      message = '[HipChat] all api tokens are dead. stop posting messages for 5 min.'
      conf[:admin][:imkayac].each do |name|
        ImKayac.to(name).post(message)
      end
    rescue
      log.error('failed to notify to administrators')
    end

    def conf
      @config
    end

    def log
      @logger
    end
  end
end
