module Ikasan
  class ExcessMessageCount < StandardError; end
  class Restrictor
    def initialize(message_count, duration)
      @message_count = message_count
      @duration = duration
      @counter = {}
    end

    def increase_sent_count(room)
      @counter[room] ||= []
      @counter[room] << Time.now.to_i
    end

    def sendable?(room)
      return true if @counter[room].nil? || @counter[room].empty?
      limit = Time.now.to_i - @duration
      @counter[room] = @counter[room].partition { |t| t >= limit }
      @counter[room].length <= @message_count
    end
  end
end
