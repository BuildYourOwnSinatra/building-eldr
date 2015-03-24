module Eldr
  class Route
    attr_accessor :before_filters, :after_filters

    def initialize(verb: 'GET', path: '/', name: nil, handler: nil)
      @before_filters, @after_filters = [], []
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

      before_filters.each { |filter| filter.call(env) }
      response = @handler.call(env)
      after_filters.each { |filter| filter.call(env) }
      response
    end
  end
end
