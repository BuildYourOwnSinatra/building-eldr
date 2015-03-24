require 'forwardable'
require_relative 'builder'
require_relative 'matcher'
require_relative 'route'
require_relative 'recognizer'

module Eldr
  class App
    class << self
      extend Forwardable
      attr_accessor :builder
      def_delegators :builder, :map, :use

      def builder
        @builder ||= Builder.new
      end

      def inherited(base)
        base.builder.use builder.middleware
      end

      alias_method :_new, :new
      def new(*args, &block)
        builder.run _new(*args, &block)
        builder
      end

      def call(env)
        new.call(env)
      end

      attr_accessor :routes
      def routes
        @routes ||= { delete: [], get: [], head: [], options: [], patch: [], post: [], put: [] }
      end

      def add(verb: :get, path: '/', handler: nil)
        handler = Proc.new if block_given?
        route =  Route.new(verb: verb, path: path, handler: handler)
        routes[verb] << route
        route
      end
      alias_method :<<, :add

      HTTP_VERBS = %w(DELETE GET HEAD OPTIONS PATCH POST PUT)
      HTTP_VERBS.each do |verb|
        define_method verb.downcase.to_sym do |path, *args, &block|
          handler = Proc.new(&block) if block
          handler ||= args.pop if args.last.respond_to?(:call)
          options ||= args.pop if args.last.is_a?(Hash)
          options ||= {}
          add({verb: verb.downcase.to_sym, path: path, handler: handler}.merge!(options))
        end
      end
    end

    def self.recognizer
      @recognizer ||= Recognizer.new(routes)
    end

    def recognize(env)
      self.class.recognizer.call(env)
    end

    def call(env)
      dup.call!(env)
    end

    # The real call method
    def call!(env)
      @env = env

      recognize(env).each do |route|
        env['eldr.route'] = route
        catch(:pass) { return route.call(env) }
      end
      rescue => error
        if error.respond_to? :call
          error.call(env)
        else
          raise error
        end
    end
  end
end
