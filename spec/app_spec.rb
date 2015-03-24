describe Eldr::App do
  describe '.before' do
    it 'adds a before filter' do
      bob = Class.new(Eldr::App)
      bob.before {}
      bob.before(:cats) { }
      expect(bob.before_filters[:all].length).to eq(1)
      expect(bob.before_filters[:cats].length).to eq(1)
    end
  end

  describe '.after' do
    it 'adds an before filter' do
      bob = Class.new(Eldr::App)
      bob.after {}
      bob.after(:cats) { }
      expect(bob.after_filters[:all].length).to eq(1)
      expect(bob.after_filters[:cats].length).to eq(1)
    end
  end

  describe '.inherited' do
    it 'inherits configuration' do
      bob = Class.new(Eldr::App)
      bob.set(:bob, 'what about him?')

      inherited = Class.new(bob)
      expect(inherited.configuration.bob).to eq('what about him?')
    end
  end
end
