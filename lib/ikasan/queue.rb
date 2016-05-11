module Ikasan
  class Queue
    def initialize
      @queues = {}
    end

    def empty?
      @queues.empty?
    end

    def unshift(q)
      @queues[q[:room]] ||= []
      @queues[q[:room]].unshift(q)
    end

    def set(q)
      @queues[q[:room]] ||= []
      @queues[q[:room]] << q
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
  end
end
