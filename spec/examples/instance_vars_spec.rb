describe 'InstanceVarsExample' do
  let(:app) do
    path = File.expand_path('../../examples/instance_vars.ru', File.dirname(__FILE__))
    Rack::Builder.parse_file(path).first
  end

  let(:rt) do
    Rack::Test::Session.new(app)
  end

  describe 'GET /instance-var' do
    it 'returns cats' do
      response = rt.get('/instance-var')
      expect(response.body).to eq('cats')
    end
  end
end
