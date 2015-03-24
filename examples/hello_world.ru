class HelloWorld < Eldr::App
  get '/' do
    [200, {}, ['Hello World!']]
  end
end

run HelloWorld
