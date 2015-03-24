class InstanceVarsExample < Eldr::App
  before do
    @instance_var = 'cats'
  end

  get '/instance-var' do
    [200, {}, [@instance_var]]
  end
end

run InstanceVarsExample
