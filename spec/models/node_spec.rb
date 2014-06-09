describe Node do
  context 'validations' do
    it { should validate_presence_of :osm_node_id }
    it { should validate_presence_of :crime_rating }
    it { should validate_presence_of :lat }
    it { should validate_presence_of :lon }
  end

  context 'associations' do
    it { should have_many :waypoints }
    it { should have_many :highways }
  end
end