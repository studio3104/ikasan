require 'toml'

module Ikasan
  class Config
    def initialize(config_file)
      config = TOML.load_file(config_file)
      @config = symbolize_recursive(config)
    end

    def [](key)
      @config[key]
    end

    private

    def symbolize_recursive(obj)
      case obj
      when Hash
        Hash[ obj.map { |k,v| [ k.to_sym, symbolize_recursive(v) ] } ]
      when Array
        obj.map { |v| symbolize_recursive(v) }
      else
        obj
      end
    end
  end
end
