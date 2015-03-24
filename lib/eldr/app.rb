require 'forwardable'
require_relative 'configuration'
require_relative 'builder'
require_relative 'matcher'
require_relative 'route'
require_relative 'recognizer'

module Eldr
  class App
    attr_accessor :configuration

    class << self
      extend Forwardable
      attr_accessor :builder, :configuration
      def_delegators :builder, :map, :use

      def configuration
        @configuration ||= Configuration.new
      end
      alias_method :config, :configuration

      def set(key, value)
        configuration.set(key, value)
      end

      def builder
        @builder ||= Builder.new
      end

      def inherited(base)
        base.builder.use builder.middleware
        base.configuration.merge!(configuration)
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
        route =  Route.new(verb: verb, path: path, name: name, handler: handler)

        route.before_filters = before_filters[name] if before_filters.include? name
        route.after_filters  = before_filters[name] if before_filters.include? name

        route.before_filters.push(*before_filters[:all])
        route.after_filters.push(*before_filters[:all])

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

      def before_filters
        @before_filters ||= { all: [] }
      end

      def after_filters
        @after_filters ||= { all: [] }
      end

      def before(*route_names, &block)
        *route_names = [:all] if route_names.empty?
        route_names.each do |route_name|
          before_filters[route_name] ||= []
          before_filters[route_name] << block
        end
      end

      def after(*route_names, &block)
        *route_names = [:all] if route_names.empty?
        route_names.each do |route_name|
          after_filters[route_name] ||= []
          after_filters[route_name] << block
        end
      end
    end

    def initialize(configuration = nil)
      configuration ||= self.class.configuration
      @configuration = configuration
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
        catch(:pass) { return route.call(env, app: self) }
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
