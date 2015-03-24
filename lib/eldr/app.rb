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
    end

    def call(env)
      dup.call!(env)
    end

    # The real call method
    def call!(env)
    end
  end
end
