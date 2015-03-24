module Eldr
  class Route
    def initialize(verb: 'GET', path: '/', name: nil, handler: nil)
      @path, @verb, @name, @handler = path, verb.to_s.upcase, name, handler
      @handler = create_handler(handler)
    end

    def create_handler(handler)
      return handler if handler.respond_to? :call

      if handler.is_a? String
        controller, method = handler.split('#')

        proc { |env|
          obj = Object.const_get(controller).new
          obj.send(method.to_sym, env)
        }
      end
    end

    def matcher
      @matcher ||= Matcher.new(@path, capture: @capture)
    end

    def match(pattern)
      matcher.match(pattern)
    end

    def call(env)
      @env = env

      @handler.call(env)
    end
  end
end
