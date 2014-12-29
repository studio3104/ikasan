require 'thread'
require 'json'

module Ikasan
  class Mapping
    include Enumerable

    def initialize(file, logger)
      @file = file
      @logger = logger
      @room_mapping_of = parse_mapping_file()
      @thread = Thread.new(&method(:monitor_mapping_file))
    end

    def empty?
      @room_mapping_of.empty?
    end

    def keys
      @room_mapping_of.keys
    end

    def values
      @room_mapping_of.values
    end

    def each
      @room_mapping_of.each do |channel, room|
        yield channel, room
      end
    end

    def [](channel)
      @room_mapping_of[channel]
    end

    private

    def parse_mapping_file
      mapping = {}
      tsv = File.read(@file)
      tsv.each_line do |line|
        channel, room = line.split("\t").map { |l| l.strip }
        mapping[channel] ||= []
        mapping[channel] << room
      end
      log.info('rehash mapping') { mapping.to_json }
      mapping
    end

    # 5分ごとにマッピングファイルのmtime監視して、ファイルに変更があったら定義を再読み込みする
    def monitor_mapping_file
      mtime = File.mtime(@file)
      loop do
        sleep 300
        begin
          _mtime = File.mtime(@file)
          next if mtime == _mtime
          @room_mapping_of = parse_mapping_file()
        rescue
          log.warn('monitor mapping file') { "#{$!.class.to_s}: #{$!.message}" }
        end
        mtime = _mtime
      end
    end

    def log
      @logger
    end
  end
end
