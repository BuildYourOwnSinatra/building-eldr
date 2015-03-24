describe 'StackAppExample' do
  let(:app) do
    path = File.expand_path('../../examples/stack_app_example.ru', File.dirname(__FILE__))
    Rack::Builder.parse_file(path).first
  end

  let(:rt) do
    Rack::Test::Session.new(app)
  end

  describe 'GET /other' do
    it 'returns Other App' do
      response = rt.get('/other')
      expect(response.body).to eq 'Other App'
    end
  end

  describe 'GET /' do
    it 'returns the counter' do
      response = rt.get('/')
      expect(response.body).to eq '2'
    end
  end
end
