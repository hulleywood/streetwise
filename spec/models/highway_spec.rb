describe Highway do
  context 'associations' do
    it { should have_many :waypoints }
    it { should have_many :nodes }
  end
end