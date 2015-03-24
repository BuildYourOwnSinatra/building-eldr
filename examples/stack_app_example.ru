class SimpleCounterMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    env['eldr.simple_counter'] ||= 0
    env['eldr.simple_counter'] += 1
    @app.call(env)
  end
end

class OtherApp < Eldr::App
  def call!(env)
    [200, {}, ['Other App']]
  end
end

class StackAppExample < Eldr::App
  use SimpleCounterMiddleware
  map '/other' do
    run OtherApp
  end

  def call!(env)
    [200, {}, [env['eldr.simple_counter']]]
  end
end

run StackAppExample
