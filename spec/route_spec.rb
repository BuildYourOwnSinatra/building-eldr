describe Eldr::Route do
  describe '.new' do
    it 'returns a new instance' do
      expect(Eldr::Route.new).to be_instance_of Eldr::Route
    end
  end

  describe '#match' do
    let(:route) { Eldr::Route.new(path: '/cats/:id') }

    context 'when the path matches' do
      it 'returns MatchData' do
        expect(route.match('/cats/bob')).to be_instance_of MatchData
      end

      it 'returns the splats' do
        expect(route.match('/cats/bob')[:id]).to eq('bob')
      end
    end

    context 'when the path does not match' do
      it 'returns nil' do
        expect(route.match('/dogs/bob')).to be_nil
      end
    end
  end
end
