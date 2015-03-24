module Eldr
  class App
    def self.call(env)
      self.new.call()
    end

    def call(env)
      dup.call!(env)
    end

    # The real call method
    def call!(env)
    end
  end
end
