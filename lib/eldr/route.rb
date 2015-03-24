module Eldr
  class Route
    attr_accessor :before_filters, :after_filters, :app, :handler

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

    def call(env, app: nil)
      @env = env
      @app ||= app

      call_before_filters(env)
      resp = call_handler(env)
      call_after_filters(env)

      resp
    end

    def call_before_filters(env)
      if app
        app.class.before_filters[:all].each { |filter| app.instance_exec(env, &filter) }
        before_filters.each                 { |filter| app.instance_exec(env, &filter) }
      else
        before_filters.each { |filter| filter.call(env) }
      end
    end

    def call_after_filters(env)
      if app
        app.class.after_filters[:all].each { |filter| app.instance_exec(env, &filter) }
        after_filters.each                 { |filter| app.instance_exec(env, &filter) }
      else
        after_filters.each { |filter| filter.call(env) }
      end
    end

    def call_handler(env)
      if app and handler.is_a? Proc
        app.instance_exec(env, &handler)
      else
        handler.call(env)
      end
    end
  end
end
