module Eldr
  class Configuration
    attr_accessor :table

    def initialize
      defaults = { lock: false }
      table.merge!(defaults)
    end

    def merge!(hash)
      hash = hash.table unless hash.is_a? Hash
      @table.merge!(hash)
    end

    def set(key, value)
      @table[key] = value
    end

    def table
      @table ||= {}
    end

    def method_missing(method, *args)
      if !args.empty? # we assume we are setting something
        set(method.to_s.gsub(/\=$/, '').to_sym, args.pop)
      else
        # A hash accessor returns nil when there is existing element
        # No special code necessary for returing nil!
        @table[method.to_s.gsub(/\?$/, '').to_sym]
      end
    end
  end
end
