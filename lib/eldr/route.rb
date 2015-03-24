module Eldr
  class Route
    def initialize(verb: 'GET', path: '/', name: nil, handler: nil)
      @path, @verb, @name, @handler = path, verb.to_s.upcase, name, handler
    end

    def matcher
      @matcher ||= Matcher.new(@path, capture: @capture)
    end

    def match(pattern)
      matcher.match(pattern)
    end
  end
end
