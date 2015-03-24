class SimpleMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    env['eldr.simple_counter'] ||= 0
    env['eldr.simple_counter'] += 1
    @app.call(env)
  end
end

class TestInheritanceApp < Eldr::App
  use SimpleMiddleware
end

class InheritedApp < TestInheritanceApp
  def call!(env)
    [200, {}, [env['eldr.simple_counter']]]
  end
end

run InheritedApp
