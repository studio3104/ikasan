module Ikasan
  class Queue
    def initialize
      @queues = {}
      @frozen = {}
    end

    def empty?
      @queues.empty?
    end

    def unshift(q)
      @queues[q[:room]] ||= []
      @queues[q[:room]].unshift(q)
    end

    def set(q)
      if frozen_rooms.include?(q[:room])
        freeze(q)
      else
        @queues[q[:room]] ||= []
        @queues[q[:room]] << q
      end
    end
    alias << set

    def retrieve
      queue = []
      @queues.keys.each do |room|
        queue << @queues[room].shift
        @queues.delete(room) if @queues[room].empty?
      end
      queue
    end

    def freeze(q, duration=0)
      if @frozen[q[:room]]
        @frozen[q[:room]][:queues] << q
      else
        till = Time.now.to_i + duration + 1
        stacked_queues = @queues.delete(q[:room])
        queues = stacked_queues.nil? ? [q] : [q].concat(stacked_queues)
        @frozen[q[:room]] = {till: till, queues: queues}
      end
    end

    def defrost!
      now = Time.now.to_i
      frozen = @frozen.clone
      frozen.each do |room, data|
        if data[:till] <= now
          @queues[room] = data[:queues]
          @frozen.delete(room)
        end
      end
    end

    def frozen_rooms
      @frozen.keys
    end
  end
end
